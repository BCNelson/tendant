# Root Makefile shim — delegates to `just` so the common verbs work verbatim
# without abandoning the existing `just` task runner. Running the local stack
# (Postgres + the live-reloading core) is `devenv up`, not a make/just recipe.

.PHONY: test generate

test:
	just test

generate:
	just generate
