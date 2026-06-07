package server

import (
	"net/http"
	"time"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/extension"
	"github.com/99designs/gqlgen/graphql/handler/lru"
	"github.com/99designs/gqlgen/graphql/handler/transport"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/gorilla/websocket"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/vektah/gqlparser/v2/ast"

	"github.com/bcnelson/tendant/services/api/graph"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
	"github.com/bcnelson/tendant/services/api/internal/push"
	"github.com/bcnelson/tendant/services/api/internal/realtime"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// Options carries the optional wiring for the chi router. Zero values
// mean "Phase 0/1 mode": no auth middleware, no subscription transport,
// no push surface, no overseer. Phase 2/3/4 fill these in.
type Options struct {
	Dispatcher   *realtime.Dispatcher
	PushSelector push.Selector
	PushQueue    string
	SetupSecret  *auth.SetupSecretState
	Overseer     overseer.Grader            // Phase 4 — gate's Layer-4 grader; nil = Phase-3 fallthrough
	ToolRegistry *tools.Registry            // Phase 4 — used by auto-approve dispatch path
	GateScript   gatescript.ScriptEvaluator // Phase 5 — gate's Layer-3 evaluator; nil = no script layer
}

// New builds the chi router with the gqlgen handler mounted at /graphql,
// a playground at /playground, and a /healthz endpoint pinging the pool.
// dctx may be nil for callers that don't need mutation-side DBOS.
func New(pool *pgxpool.Pool, dctx dbos.DBOSContext, opts Options) http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(30 * time.Second))

	q := db.New(pool)
	resolver := &graph.Resolver{
		Pool:            pool,
		Queries:         q,
		DBOS:            dctx,
		Dispatcher:      opts.Dispatcher,
		PushSelector:    opts.PushSelector,
		PushQueueName:   opts.PushQueue,
		SetupSecret:     opts.SetupSecret,
		Overseer:        opts.Overseer,
		ToolRegistry:    opts.ToolRegistry,
		ScriptEvaluator: opts.GateScript,
	}

	// Mount /graphql with auth.Middleware applied via With() so that both
	// "/graphql" (exact) and the chi-default-redirected "/graphql/" trailing-
	// slash variant resolve through the middleware. Prior shape (Route +
	// nested Handle("/") + a separate legacy Handle without auth) created a
	// path where exact "/graphql" bypassed auth — broke session-bearer tests.
	r.With(auth.Middleware(q)).Handle("/graphql", graphqlHandler(resolver))
	r.Handle("/playground", playground.Handler("Tendant", "/graphql"))
	// Phase 4/5: extend /healthz with the overseer + gate-script rate counters
	// when wired.
	var rate RateProvider
	if g, ok := opts.Overseer.(RateProvider); ok {
		rate = g
	}
	var scriptRate GateScriptRateProvider
	if s, ok := opts.GateScript.(GateScriptRateProvider); ok {
		scriptRate = s
	}
	r.Get("/healthz", healthzWithOverseer(pool, rate, scriptRate))

	return r
}

func graphqlHandler(resolver *graph.Resolver) http.Handler {
	srv := handler.New(graph.NewExecutableSchema(graph.Config{Resolvers: resolver}))
	srv.AddTransport(transport.POST{})
	srv.AddTransport(transport.GET{})
	srv.AddTransport(transport.Options{})

	// WebSocket transport for subscriptions (graphql-transport-ws).
	srv.AddTransport(&transport.Websocket{
		Upgrader: websocket.Upgrader{
			CheckOrigin: func(*http.Request) bool { return true },
		},
		KeepAlivePingInterval: 10 * time.Second,
		InitFunc:              auth.WebsocketInitFunc(resolver.Queries),
	})

	srv.SetQueryCache(lru.New[*ast.QueryDocument](1000))
	srv.Use(extension.Introspection{})
	return srv
}
