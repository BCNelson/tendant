package webui

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
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
