package auth

import (
	"context"
	"errors"
	"strings"

	"github.com/99designs/gqlgen/graphql/handler/transport"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ErrWebsocketUnauthorized is returned from the gqlgen WebSocket InitFunc to
// trigger a 4401 close per graphql-transport-ws convention.
var ErrWebsocketUnauthorized = errors.New("unauthorized: bad or missing bearer in connection_init payload")

// WebsocketInitFunc builds a gqlgen `transport.Websocket.InitFunc` that reads
// the bearer from the connection_init payload and attaches the resolved
// Principal to the per-connection ctx. Missing bearer is allowed (subscriptions
// fail at resolve time via Can, mirroring HTTP). Invalid bearer triggers a
// 4401 close.
func WebsocketInitFunc(q *db.Queries) transport.WebsocketInitFunc {
	return func(ctx context.Context, initPayload transport.InitPayload) (context.Context, *transport.InitPayload, error) {
		raw := readBearerFromInitPayload(initPayload)
		if raw == "" {
			return ctx, nil, nil
		}
		p, _, err := Resolve(ctx, q, raw)
		if err != nil {
			return ctx, nil, ErrWebsocketUnauthorized
		}
		return WithPrincipal(ctx, p), nil, nil
	}
}

func readBearerFromInitPayload(payload transport.InitPayload) string {
	if payload == nil {
		return ""
	}
	for _, k := range []string{"authorization", "Authorization"} {
		if v, ok := payload[k]; ok {
			if s, ok := v.(string); ok {
				if strings.HasPrefix(s, "Bearer ") {
					return strings.TrimSpace(s[len("Bearer "):])
				}
				return strings.TrimSpace(s)
			}
		}
	}
	return ""
}
