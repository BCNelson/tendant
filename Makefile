# Root Makefile shim — delegates to `just` so the spec's `make up`/`make down`
# verbs work verbatim without abandoning the existing `just` task runner.

.PHONY: up down test generate

up:
	just up

down:
	just down

test:
	just test

generate:
	just generate
