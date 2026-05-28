// Package db hosts the Postgres migrations as an embedded filesystem. The
// services/api module reads from Migrations at startup via goose.
package db

import "embed"

//go:embed migrations/*.sql
var Migrations embed.FS
