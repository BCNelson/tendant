package auth

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Middleware attaches the resolved Principal to the request context when the
// bearer is valid; unauthenticated requests still pass through (resolvers
// that require a principal fail with UNAUTHORIZED via Can). Touches
// last_seen_at opportunistically in a goroutine on each authenticated hit.
func Middleware(q *db.Queries) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			raw := extractBearer(r.Header.Get("Authorization"))
			if raw == "" {
				next.ServeHTTP(w, r)
				return
			}
			p, sess, err := Resolve(r.Context(), q, raw)
			if err != nil {
				// Unauthenticated continues; resolvers gate.
				next.ServeHTTP(w, r)
				return
			}
			ctx := WithPrincipal(r.Context(), p)
			if sess != nil {
				go touchLastSeen(q, sess.ID)
			}
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func touchLastSeen(q *db.Queries, sessID uuid.UUID) {
	bg, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err := q.TouchSessionLastSeen(bg, sessID); err != nil {
		slog.Debug("touch session last_seen failed", "err", err)
	}
}

func extractBearer(h string) string {
	if h == "" {
		return ""
	}
	const prefix = "Bearer "
	if !strings.HasPrefix(h, prefix) {
		return ""
	}
	return strings.TrimSpace(h[len(prefix):])
}
