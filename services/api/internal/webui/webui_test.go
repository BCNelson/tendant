package webui

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

// get issues a GET against the handler and returns status, content-type, body.
func get(t *testing.T, h http.Handler, path string) (int, string, string) {
	t.Helper()
	req := httptest.NewRequest(http.MethodGet, path, nil)
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	body, _ := io.ReadAll(rec.Result().Body)
	return rec.Code, rec.Result().Header.Get("Content-Type"), string(body)
}

// headers issues a GET and returns the response header.
func headers(t *testing.T, h http.Handler, path string) http.Header {
	t.Helper()
	req := httptest.NewRequest(http.MethodGet, path, nil)
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec.Result().Header
}

// waitForETag polls path until it returns an ETag, since the hash map is built
// in a background goroutine and is not guaranteed ready on the first request.
func waitForETag(t *testing.T, h http.Handler, path string) string {
	t.Helper()
	for i := 0; i < 200; i++ {
		if et := headers(t, h, path).Get("ETag"); et != "" {
			return et
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatalf("no ETag for %s after waiting for the background hash", path)
	return ""
}

func TestHandler(t *testing.T) {
	h := Handler()

	if !Built() {
		// No real build staged (e.g. fresh checkout): every path returns the
		// placeholder. That's the secure default; the e2e cases below need a
		// real bundle, so stop here.
		code, ct, body := get(t, h, "/")
		if code != http.StatusOK {
			t.Fatalf("placeholder root: got %d want 200", code)
		}
		if !strings.Contains(ct, "text/html") {
			t.Errorf("placeholder content-type = %q", ct)
		}
		if !strings.Contains(body, "has not been built") {
			t.Errorf("placeholder body unexpected: %q", body)
		}
		t.Skip("no real web build embedded; ran placeholder checks only")
	}

	t.Run("root serves index.html", func(t *testing.T) {
		code, ct, body := get(t, h, "/")
		if code != http.StatusOK {
			t.Fatalf("got %d want 200", code)
		}
		if !strings.Contains(ct, "text/html") {
			t.Errorf("content-type = %q want html", ct)
		}
		if !strings.Contains(body, "<base href=\"/\"") {
			t.Errorf("index.html missing expected base href; body head: %q", body[:min(200, len(body))])
		}
	})

	t.Run("real asset is served verbatim", func(t *testing.T) {
		code, ct, body := get(t, h, "/flutter_bootstrap.js")
		if code != http.StatusOK {
			t.Fatalf("got %d want 200", code)
		}
		if !strings.Contains(ct, "javascript") {
			t.Errorf("content-type = %q want javascript", ct)
		}
		if len(body) == 0 {
			t.Error("empty bootstrap body")
		}
	})

	t.Run("per-build files are short-cached, never no-cache", func(t *testing.T) {
		// index.html and the entry/app-code files reuse their names every build
		// (fingerprinting is deferred), so they get a brief max-age, not immutable.
		for _, p := range []string{"/", "/flutter_bootstrap.js", "/main.dart.js"} {
			cc := headers(t, h, p).Get("Cache-Control")
			if cc != "public, max-age=60" {
				t.Errorf("%s: Cache-Control = %q want \"public, max-age=60\"", p, cc)
			}
			if strings.Contains(cc, "no-cache") {
				t.Errorf("%s: must not be no-cache; got %q", p, cc)
			}
		}
		// They still carry an ETag so the post-minute revalidation is a 304.
		if et := waitForETag(t, h, "/"); et == "" {
			t.Error("missing ETag on index.html")
		}
	})

	t.Run("static assets are cached immutably (never no-cache)", func(t *testing.T) {
		// favicon.png is not a per-build file, so it is cached hard.
		cc := headers(t, h, "/favicon.png").Get("Cache-Control")
		if !strings.Contains(cc, "immutable") || !strings.Contains(cc, "max-age=") {
			t.Errorf("Cache-Control = %q want immutable long max-age", cc)
		}
		if strings.Contains(cc, "no-cache") {
			t.Errorf("must not be no-cache; got %q", cc)
		}
	})

	t.Run("matching If-None-Match revalidates to 304 (no body)", func(t *testing.T) {
		// Learn the ETag (waiting for the background hash to be ready).
		etag := waitForETag(t, h, "/flutter_bootstrap.js")

		// Conditional re-fetch with the same ETag → 304, empty body.
		req2 := httptest.NewRequest(http.MethodGet, "/flutter_bootstrap.js", nil)
		req2.Header.Set("If-None-Match", etag)
		rec2 := httptest.NewRecorder()
		h.ServeHTTP(rec2, req2)
		res2 := rec2.Result()
		if res2.StatusCode != http.StatusNotModified {
			t.Fatalf("conditional GET: got %d want 304", res2.StatusCode)
		}
		body, _ := io.ReadAll(res2.Body)
		if len(body) != 0 {
			t.Errorf("304 should have no body, got %d bytes", len(body))
		}
	})

	t.Run("unknown path falls back to index.html (SPA routing)", func(t *testing.T) {
		code, ct, body := get(t, h, "/inbox/deep/link")
		if code != http.StatusOK {
			t.Fatalf("got %d want 200 (SPA fallback)", code)
		}
		if !strings.Contains(ct, "text/html") {
			t.Errorf("content-type = %q want html", ct)
		}
		if !strings.Contains(body, "flutter_bootstrap.js") {
			t.Errorf("fallback did not return index.html")
		}
	})
}
