// Package webui embeds the compiled Flutter web build and serves it as a
// single-page app from the same origin as the GraphQL API.
//
// The build artifacts live under dist/. Nothing there is committed except a
// .gitignore (which keeps the directory present so the //go:embed always
// compiles); the real bundle is produced by `just build-web` (or the Docker
// flutter stage) before `go build`. When no real build is embedded the
// handler serves an in-code placeholder page, so the module always works
// whether or not a web build is present.
//
// Caching is tiered. Filename fingerprinting is deferred (the build does not yet
// hash filenames — see scripts/fingerprint-web.mjs), so the per-build entry and
// app-code files (index.html, flutter_bootstrap.js, main.dart.js, deferred
// *.part.js, …) reuse the same name on every build and must not be cached hard:
// they are served `public, max-age=60` — cached for a minute (real cache hits,
// no revalidation), so a new deploy is picked up within that window and never
// served stale. Everything else — the canvaskit engine, fonts, images, icons —
// is large and effectively static, so it is served `public, max-age=31536000,
// immutable` for true cache hits with no round-trip. Nothing is `no-cache`.
//
// Every file also carries a content-hash ETag (embed.FS files have a zero
// modtime, so without it browsers fall back to unreliable heuristic caching; the
// ETag also makes the post-minute revalidation of the short-cached files a cheap
// 304). The Flutter build runs with `--pwa-strategy=none`, so the only service
// worker emitted is the self-unregistering stub that tears down any caching SW a
// prior build left on a client; freshness is owned by these HTTP headers.
//
// When fingerprinting is later enabled, the short-cached set collapses to just
// index.html (everything else becomes content-addressed and immutable).
//
// The ETags are content hashes over the whole build (main.dart.js + canvaskit
// wasm are multi-MB), so they are computed in a background goroutine rather than
// on the boot path. Until that finishes — typically a few ms — assets are still
// served with `no-cache` but without an ETag, so they are fresh, just full 200s
// instead of cheap 304s for the first handful of requests.
package webui

import (
	"crypto/sha256"
	"embed"
	"encoding/hex"
	"io"
	"io/fs"
	"mime"
	"net/http"
	"path"
	"strings"
	"sync/atomic"
	"time"
)

// placeholderHTML is served when no real Flutter build has been embedded.
const placeholderHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tendant</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 40rem; margin: 4rem auto; padding: 0 1rem; line-height: 1.5; }
    code { background: #f0f0f0; padding: 0.1rem 0.3rem; border-radius: 3px; }
  </style>
</head>
<body>
  <h1>Tendant</h1>
  <p>The web UI has not been built into this binary.</p>
  <p>Run <code>just build-web</code> (which compiles the Flutter app and copies
     it into the embed directory) and rebuild the server, or use a release
     image where the Docker build stage produces the bundle.</p>
  <p>The GraphQL API is at <code>/graphql</code> and the playground at
     <code>/playground</code>.</p>
</body>
</html>
`

//go:embed all:dist
var embedded embed.FS

// dist returns the embedded build rooted at dist/.
func dist() fs.FS {
	sub, err := fs.Sub(embedded, "dist")
	if err != nil {
		// dist is always embedded (a placeholder index.html is committed), so
		// this only fires on a programmer error renaming the directory.
		panic("webui: embedded dist/ missing: " + err.Error())
	}
	return sub
}

// Built reports whether a real Flutter build is embedded (as opposed to only
// the committed placeholder). It detects the Flutter bootstrap script, which
// the placeholder does not contain.
func Built() bool {
	if _, err := fs.Stat(dist(), "flutter_bootstrap.js"); err == nil {
		return true
	}
	return false
}

// buildETags walks the embedded build and computes a strong content-hash ETag
// per file. It reads every byte (hence the off-boot-path goroutine in Handler).
func buildETags(root fs.FS) map[string]string {
	out := make(map[string]string)
	_ = fs.WalkDir(root, ".", func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return nil
		}
		data, readErr := fs.ReadFile(root, p)
		if readErr != nil {
			return nil
		}
		sum := sha256.Sum256(data)
		// 128 bits of SHA-256 is ample to distinguish builds; quoted per the
		// ETag grammar (RFC 7232).
		out[p] = `"` + hex.EncodeToString(sum[:16]) + `"`
		return nil
	})
	return out
}

// immutableCacheControl caches a file for a year with no revalidation. Safe only
// for effectively-static files (engine, fonts, images) — never for the
// stable-named per-build entry/app-code files, which would go stale (see
// shortCacheControl).
const immutableCacheControl = "public, max-age=31536000, immutable"

// shortCacheControl caches the per-build entry/app-code files for a minute with
// no revalidation, so a new deploy is picked up within the window without a
// per-request round-trip. Used while filename fingerprinting is deferred; never
// `no-cache`.
const shortCacheControl = "public, max-age=60"

// shortCached is the set of files that reuse the same name on every build, so
// (absent fingerprinting) they must not be cached hard. Deferred *.part.js
// chunks are matched by suffix in cacheControlFor.
var shortCached = map[string]bool{
	"index.html":                true,
	"flutter_bootstrap.js":      true,
	"flutter.js":                true,
	"flutter_service_worker.js": true,
	"main.dart.js":              true,
	"main.dart.mjs":             true,
	"main.dart.wasm":            true,
	"version.json":              true,
	"manifest.json":             true,
}

// cacheControlFor returns the Cache-Control policy for an embedded file:
// short-cache the per-build files, cache everything else immutably. See the
// package doc for the rationale.
func cacheControlFor(name string) string {
	if shortCached[name] || strings.HasSuffix(name, ".part.js") {
		return shortCacheControl
	}
	return immutableCacheControl
}

// contentTypeFor resolves a Content-Type from the extension alone (no file
// read), pinning the web-critical types explicitly — canvaskit needs
// application/wasm for streaming compilation, and the platform mime table is
// unreliable for .js/.wasm across OSes. Returns "" for unknown extensions, in
// which case http.ServeContent sniffs the body.
func contentTypeFor(name string) string {
	switch strings.ToLower(path.Ext(name)) {
	case ".js", ".mjs":
		return "text/javascript; charset=utf-8"
	case ".wasm":
		return "application/wasm"
	case ".json":
		return "application/json; charset=utf-8"
	case ".css":
		return "text/css; charset=utf-8"
	case ".html", ".htm":
		return "text/html; charset=utf-8"
	}
	return mime.TypeByExtension(path.Ext(name))
}

// fileExists reports whether name is a regular file in root (not a directory).
func fileExists(root fs.FS, name string) bool {
	info, err := fs.Stat(root, name)
	return err == nil && !info.IsDir()
}

// Handler serves the embedded web build with SPA fallback: requests that map
// to an embedded file return that file; anything else returns index.html so
// client-side (deep-link / reload) routing works. Mount it as a catch-all
// (e.g. chi `Handle("/*", ...)`); explicit API routes registered on the same
// router take precedence, so only unmatched paths reach this handler.
//
// Every served asset carries a Cache-Control (see cacheControlFor: short-cache
// the per-build files, immutable for static assets) and — once the background
// hash completes — a content-hash ETag; 304 revalidation is handled by
// http.ServeContent. See the package doc for the caching rationale.
func Handler() http.Handler {
	root := dist()

	if !Built() {
		// No real build embedded — serve the placeholder for every path. Never
		// cache it: it is a transient stand-in for the real bundle.
		return http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Cache-Control", "no-store")
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			_, _ = w.Write([]byte(placeholderHTML))
		})
	}

	// Compute ETags off the boot path; serve immediately meanwhile (no ETag
	// until the pointer is populated, which is the only observable difference).
	var etags atomic.Pointer[map[string]string]
	go func() {
		m := buildETags(root)
		etags.Store(&m)
	}()

	serve := func(w http.ResponseWriter, r *http.Request, name string) {
		f, err := root.Open(name)
		if err != nil {
			http.NotFound(w, r)
			return
		}
		defer func() { _ = f.Close() }()
		rs, ok := f.(io.ReadSeeker)
		if !ok {
			// embed.FS regular files are always seekable; this is a safety net.
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		h := w.Header()
		h.Set("Cache-Control", cacheControlFor(name))
		if ct := contentTypeFor(name); ct != "" {
			h.Set("Content-Type", ct)
		}
		if m := etags.Load(); m != nil {
			if et, ok := (*m)[name]; ok {
				h.Set("ETag", et)
			}
		}
		// Zero modtime → no Last-Modified; ServeContent still honors the ETag
		// for If-None-Match (304) and supports Range/HEAD.
		http.ServeContent(w, r, name, time.Time{}, rs)
	}

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		upath := strings.TrimPrefix(path.Clean("/"+r.URL.Path), "/")
		if upath != "" && fileExists(root, upath) {
			serve(w, r, upath)
			return
		}
		// Root, or an unknown path → SPA fallback to index.html.
		serve(w, r, "index.html")
	})
}
