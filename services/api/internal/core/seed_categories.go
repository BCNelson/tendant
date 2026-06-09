package core

import (
	"context"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"path"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/knadh/koanf/parsers/toml"
	"github.com/knadh/koanf/providers/confmap"
	"github.com/knadh/koanf/v2"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// categoryEntry is the in-memory shape the category reconciler consumes, built
// from the embedded default categories (default_categories/) when no file drives
// the catalog, or from file/community-provided config.CategoryDef otherwise.
type categoryEntry struct {
	Key           string
	ParentKey     string // resolved parent key ("" = root)
	Label         string
	Description   string
	StageBindings json.RawMessage
	Origin        db.ConfigOrigin
}

// defaultCategoriesFS holds the built-in (core-origin) task categories, one TOML
// file per category. Each file uses the same per-file format future community
// categories will use; see categoryEntriesFor / defaultCategoryDefs.
//
//go:embed default_categories
var defaultCategoriesFS embed.FS

// defaultCategoryDefs reads every default_categories/*.toml file (one category
// each) into the same CategoryDef shape the config file uses, so built-in and
// file/community categories share one format and one conversion path.
func defaultCategoryDefs() ([]config.CategoryDef, error) {
	entries, err := fs.ReadDir(defaultCategoriesFS, "default_categories")
	if err != nil {
		return nil, fmt.Errorf("read embedded default_categories: %w", err)
	}
	defs := make([]config.CategoryDef, 0, len(entries))
	for _, e := range entries {
		if e.IsDir() || path.Ext(e.Name()) != ".toml" {
			continue
		}
		b, err := defaultCategoriesFS.ReadFile(path.Join("default_categories", e.Name()))
		if err != nil {
			return nil, fmt.Errorf("read default category %s: %w", e.Name(), err)
		}
		def, err := parseCategoryFile(b)
		if err != nil {
			return nil, fmt.Errorf("parse default category %s: %w", e.Name(), err)
		}
		defs = append(defs, def)
	}
	return defs, nil
}

// parseCategoryFile decodes a single-category TOML file into a config.CategoryDef
// using the same koanf tag semantics as cfg.Categories, so the embedded defaults
// can never diverge from how file-provided categories are parsed.
func parseCategoryFile(b []byte) (config.CategoryDef, error) {
	m, err := toml.Parser().Unmarshal(b)
	if err != nil {
		return config.CategoryDef{}, err
	}
	k := koanf.New(".")
	if err := k.Load(confmap.Provider(m, "."), nil); err != nil {
		return config.CategoryDef{}, err
	}
	var def config.CategoryDef
	if err := k.Unmarshal("", &def); err != nil {
		return config.CategoryDef{}, err
	}
	return def, nil
}

// SeedCategoryCatalog inserts the embedded default category catalog at boot.
// Idempotent: skips categories that already exist (matched by key). Equivalent to
// ReconcileCategoryCatalog with no file-provided definitions.
func SeedCategoryCatalog(ctx context.Context, q *db.Queries) error {
	return ReconcileCategoryCatalog(ctx, q, nil)
}

// ReconcileCategoryCatalog reconciles the category catalog from config. When defs
// is empty it falls back to the embedded default categories (default_categories/).
// When the config file defines categories, those are authoritative: each key is
// upserted — inserted if new, updated if present. Non-destructive: DB rows the
// file omits are left untouched. Entries are processed parent-before-child so a
// child's parent_id resolves to an already-present row.
func ReconcileCategoryCatalog(ctx context.Context, q *db.Queries, defs []config.CategoryDef) error {
	entries, err := categoryEntriesFor(defs)
	if err != nil {
		return err
	}
	fileDriven := len(defs) > 0

	// Parents must exist before children so parent_id resolves. Sorting by key
	// places a path-like parent ("communication") before its children
	// ("communication/email") lexicographically.
	sort.Slice(entries, func(i, j int) bool { return entries[i].Key < entries[j].Key })

	for _, entry := range entries {
		bindings := entry.StageBindings
		if len(bindings) == 0 {
			bindings = json.RawMessage(`{}`)
		}

		var parentID pgtype.UUID
		if entry.ParentKey != "" {
			parent, perr := q.GetTaskCategoryByKey(ctx, entry.ParentKey)
			if perr != nil {
				if errors.Is(perr, pgx.ErrNoRows) {
					return fmt.Errorf("category %q: parent %q not found (declare it before its children)", entry.Key, entry.ParentKey)
				}
				return perr
			}
			parentID = pgtype.UUID{Bytes: parent.ID, Valid: true}
		}

		var descPtr *string
		if entry.Description != "" {
			d := entry.Description
			descPtr = &d
		}

		existing, lookupErr := q.GetTaskCategoryByKey(ctx, entry.Key)
		switch {
		case lookupErr == nil:
			if !fileDriven {
				// No file drives the catalog this boot, so the embedded defaults are
				// the source of truth for core-origin rows. Re-sync a core row whose
				// stored content has drifted from the current default; leave
				// owner/community customizations (origin != core) untouched.
				if existing.Origin != db.ConfigOriginCore ||
					coreCategoryMatchesDefault(existing, parentID, entry.Label, descPtr, bindings) {
					continue
				}
				slog.InfoContext(ctx, "resyncing core category to embedded default",
					"key", entry.Key, "from_version", existing.Version)
			}
			if _, err := q.UpdateTaskCategoryByKey(ctx, db.UpdateTaskCategoryByKeyParams{
				Key:           entry.Key,
				ParentID:      parentID,
				Label:         entry.Label,
				Description:   descPtr,
				StageBindings: bindings,
			}); err != nil {
				return fmt.Errorf("reconcile category %q: update: %w", entry.Key, err)
			}
			slog.InfoContext(ctx, "reconciled category (updated)", "key", entry.Key)
		case errors.Is(lookupErr, pgx.ErrNoRows):
			if _, err := q.InsertTaskCategory(ctx, db.InsertTaskCategoryParams{
				Key:           entry.Key,
				ParentID:      parentID,
				Label:         entry.Label,
				Description:   descPtr,
				StageBindings: bindings,
				Origin:        entry.Origin,
				Version:       1,
			}); err != nil {
				return fmt.Errorf("reconcile category %q: insert: %w", entry.Key, err)
			}
			slog.InfoContext(ctx, "reconciled category (inserted)", "key", entry.Key)
		default:
			return lookupErr
		}
	}
	return nil
}

// coreCategoryMatchesDefault reports whether an existing core-origin row already
// matches the embedded default for every field the reconciler manages, so the
// boot-time re-sync can skip a no-op update and avoid a pointless version bump.
func coreCategoryMatchesDefault(existing db.TaskCategory, parentID pgtype.UUID, label string, descPtr *string, bindings json.RawMessage) bool {
	if existing.Label != label {
		return false
	}
	if !ptrStrEqual(existing.Description, descPtr) {
		return false
	}
	if existing.ParentID != parentID {
		return false
	}
	return jsonEqual(existing.StageBindings, bindings)
}

// categoryEntriesFor returns the embedded default categories (default_categories/)
// when defs is empty, else converts the file-provided definitions into catalog
// entries. Both paths run the identical conversion. Validates key, stage-binding
// keys, and origin; derives parent key from an explicit Parent or the key prefix.
func categoryEntriesFor(defs []config.CategoryDef) ([]categoryEntry, error) {
	if len(defs) == 0 {
		d, err := defaultCategoryDefs()
		if err != nil {
			return nil, err
		}
		defs = d
	}
	out := make([]categoryEntry, 0, len(defs))
	for _, d := range defs {
		key := strings.TrimSpace(d.Key)
		if key == "" {
			return nil, fmt.Errorf("category definition missing key")
		}
		origin, err := parseConfigOrigin(d.Origin)
		if err != nil {
			return nil, fmt.Errorf("category %q: %w", key, err)
		}
		bindings, err := marshalStageBindings(key, d.StageBindings)
		if err != nil {
			return nil, err
		}
		label := d.Label
		if strings.TrimSpace(label) == "" {
			label = key
		}
		out = append(out, categoryEntry{
			Key:           key,
			ParentKey:     parentKeyFor(d),
			Label:         label,
			Description:   d.Description,
			StageBindings: bindings,
			Origin:        origin,
		})
	}
	return out, nil
}

// parentKeyFor resolves a category's parent key: an explicit Parent wins, else it
// is derived from the key's path prefix ("communication/email" → "communication";
// a key with no "/" → "" root).
func parentKeyFor(d config.CategoryDef) string {
	if p := strings.TrimSpace(d.Parent); p != "" {
		return p
	}
	key := strings.TrimSpace(d.Key)
	if i := strings.LastIndex(key, "/"); i > 0 {
		return key[:i]
	}
	return ""
}

// marshalStageBindings validates the per-stage binding keys (triage|expansion|
// execution) and marshals to canonical jsonb. Unknown stages are rejected so a
// typo can't silently disable routing.
func marshalStageBindings(key string, raw map[string]map[string]any) (json.RawMessage, error) {
	if len(raw) == 0 {
		return json.RawMessage(`{}`), nil
	}
	for stage := range raw {
		if _, err := parseAgentStage(stage); err != nil {
			return nil, fmt.Errorf("category %q: stage_bindings: %w", key, err)
		}
	}
	b, err := json.Marshal(raw)
	if err != nil {
		return nil, fmt.Errorf("category %q: marshal stage_bindings: %w", key, err)
	}
	return b, nil
}
