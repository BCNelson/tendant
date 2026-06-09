// Package webui embeds the compiled Flutter web build and serves it as a
// single-page app from the same origin as the GraphQL API.
//
// The build artifacts live under dist/. Nothing there is committed except a
// .gitignore (which keeps the directory present so the //go:embed always
// compiles); the real bundle is produced by `just build-web` (or the Docker
// flutter stage) before `go build`. When no real build is embedded the
// handler serves an in-code placeholder page, so the module always works
// whether or not a web build is present.
package webui

import (
	"embed"
	"io/fs"
	"net/http"
	"strings"
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

// Handler serves the embedded web build with SPA fallback: requests that map
// to an embedded file return that file; anything else returns index.html so
// client-side (deep-link / reload) routing works. Mount it as a catch-all
// (e.g. chi `Handle("/*", ...)`); explicit API routes registered on the same
// router take precedence, so only unmatched paths reach this handler.
func Handler() http.Handler {
	root := dist()

	if !Built() {
		// No real build embedded — serve the placeholder for every path.
		return http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			_, _ = w.Write([]byte(placeholderHTML))
		})
	}

	fileServer := http.FileServer(http.FS(root))

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		upath := strings.TrimPrefix(r.URL.Path, "/")
		if upath == "" {
			fileServer.ServeHTTP(w, r) // index.html
			return
		}
		if f, err := root.Open(upath); err == nil {
			_ = f.Close()
			fileServer.ServeHTTP(w, r)
			return
		}
		// Unknown path → SPA fallback to index.html.
		r2 := r.Clone(r.Context())
		r2.URL.Path = "/"
		fileServer.ServeHTTP(w, r2)
	})
}
