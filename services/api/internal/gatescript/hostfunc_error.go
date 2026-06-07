package gatescript

import (
	"errors"

	"github.com/jackc/pgx/v5/pgconn"
)

// hostfunc_error.go centralizes the host-error trap policy (FR-007 / Q4). When
// any of the five read host functions returns an error (Postgres drop, query
// timeout, transient infra failure), the shim records the (module, name,
// SQLSTATE) on the per-call HostCallbacks and panics — wazero converts the panic
// to a guest trap, and the runner reports fail_closed_host_error rather than
// presenting a legitimate-looking empty read to the script. A transient DB blip
// must never masquerade as "no value".

// sqlState extracts the Postgres SQLSTATE from a wrapped pgconn.PgError, or "" if
// the error is not a Postgres server error (e.g. a context cancellation or a
// connection-pool error).
func sqlState(err error) string {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		return pgErr.Code
	}
	return ""
}
