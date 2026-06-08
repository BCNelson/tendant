package graph

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// configKeysImpl returns the registry merged with the boot snapshot and the DB
// overlay. Owner-only. Sensitive values are redacted (defaultValue/effectiveValue
// nil, sensitive=true).
func (r *Resolver) configKeysImpl(ctx context.Context) ([]*model.ConfigKey, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, permissionDeniedError(ctx)
	}
	var flat map[string]any
	if r.ConfigSnapshot != nil {
		flat = r.ConfigSnapshot.Flat()
	}
	out := make([]*model.ConfigKey, 0, len(config.Registry))
	for _, def := range config.Registry {
		def := def
		ck := &model.ConfigKey{
			Key:            def.Key,
			Type:           def.Type,
			Description:    def.Description,
			Reload:         string(def.Reload),
			Sensitive:      def.Sensitive,
			DbConfigurable: def.DBConfigurable,
			HotReloadable:  def.HotReloadable,
		}
		if def.ReadonlyReason != "" {
			rr := def.ReadonlyReason
			ck.ReadonlyReason = &rr
		}

		// Effective value: DB overlay wins, else the boot-resolved snapshot value.
		raw, overridden := r.ConfigOverlay.Lookup(def.Key)
		ck.Overridden = overridden

		if !def.Sensitive {
			dv := config.StringifyValue(def, def.Default)
			ck.DefaultValue = &dv
			var ev string
			if overridden {
				ev = config.DecodeStored(def, raw)
			} else if flat != nil {
				ev = config.StringifyValue(def, flat[def.Key])
			} else {
				ev = dv
			}
			ck.EffectiveValue = &ev
		}
		out = append(out, ck)
	}
	return out, nil
}

// setConfigEntryImpl validates and stores a DB-configurable key's override.
// Owner-only. The trigger fires NOTIFY config_changed; we also refresh the local
// overlay synchronously so the returned ConfigKey reflects the new value.
func (r *Resolver) setConfigEntryImpl(ctx context.Context, key, value string) (*model.ConfigKey, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, permissionDeniedError(ctx)
	}
	def, ok := config.RegistryMap()[key]
	if !ok {
		return nil, gqlerror.Errorf("unknown config key: %s", key)
	}
	if !def.DBConfigurable {
		reason := def.ReadonlyReason
		if reason == "" {
			reason = "not editable at runtime"
		}
		return nil, gqlerror.Errorf("config key %q is not DB-configurable: %s", key, reason)
	}
	encoded, err := config.EncodeValue(def, value)
	if err != nil {
		return nil, gqlerror.Errorf("%s", err.Error())
	}
	if _, err := r.Queries.UpsertConfigEntry(ctx, db.UpsertConfigEntryParams{Key: key, Value: encoded}); err != nil {
		return nil, err
	}
	if r.ConfigOverlay != nil {
		if err := r.ConfigOverlay.Refresh(ctx, key); err != nil {
			return nil, err
		}
	}
	return r.oneConfigKey(ctx, def)
}

// deleteConfigEntryImpl removes a key's override. Owner-only.
func (r *Resolver) deleteConfigEntryImpl(ctx context.Context, key string) (bool, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return false, permissionDeniedError(ctx)
	}
	if _, ok := config.RegistryMap()[key]; !ok {
		return false, gqlerror.Errorf("unknown config key: %s", key)
	}
	if err := r.Queries.DeleteConfigEntry(ctx, key); err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return false, err
	}
	if r.ConfigOverlay != nil {
		if err := r.ConfigOverlay.Refresh(ctx, key); err != nil {
			return false, err
		}
	}
	return true, nil
}

// oneConfigKey renders a single ConfigKey after a write (reuses configKeysImpl's
// projection without re-checking auth, which the caller already enforced).
func (r *Resolver) oneConfigKey(ctx context.Context, def config.KeyDef) (*model.ConfigKey, error) {
	ck := &model.ConfigKey{
		Key:            def.Key,
		Type:           def.Type,
		Description:    def.Description,
		Reload:         string(def.Reload),
		Sensitive:      def.Sensitive,
		DbConfigurable: def.DBConfigurable,
		HotReloadable:  def.HotReloadable,
	}
	if def.ReadonlyReason != "" {
		rr := def.ReadonlyReason
		ck.ReadonlyReason = &rr
	}
	raw, overridden := r.ConfigOverlay.Lookup(def.Key)
	ck.Overridden = overridden
	if !def.Sensitive {
		dv := config.StringifyValue(def, def.Default)
		ck.DefaultValue = &dv
		var ev string
		if overridden {
			ev = config.DecodeStored(def, raw)
		} else if r.ConfigSnapshot != nil {
			ev = config.StringifyValue(def, r.ConfigSnapshot.Flat()[def.Key])
		} else {
			ev = dv
		}
		ck.EffectiveValue = &ev
	}
	return ck, nil
}
