{ pkgs, lib, config, ... }:

{
  devenv.root =
    let
      devenvRoot = builtins.getEnv "DEVENV_ROOT";
    in
    if devenvRoot != "" then devenvRoot else builtins.toString ./.;

  languages.go.enable = true;
  languages.go.package = pkgs.go_1_25;

  languages.dart.enable = true;

  # Phase 5 gate-script SDK authoring:
  #   - JavaScript/npm: the AssemblyScript SDK (sdks/gate-sdk-as → npm
  #     @tendant/gate-sdk) and the vendored `asc` compiler are npm-based.
  #   - Rust + wasm32-unknown-unknown: the Rust SDK (sdks/gate-sdk-rust →
  #     crates.io tendant-gate-sdk) compiles BYO `.wasm` gate scripts.
  languages.javascript = {
    enable = true;
    npm.enable = true;
  };

  # `asc` on PATH: local Tier-1 authoring AND the server's opt-in subprocess
  # Tier-1 compile backend (TENDANT_ASC_BACKEND=subprocess).

  languages.rust = {
    enable = true;
    channel = "stable";
    targets = [ "wasm32-unknown-unknown" ];
  };

  packages = with pkgs; [
    gotools
    golangci-lint
    delve
    git
    just
    sqlc
    goose
    flutter
    assemblyscript # `asc` — Tier-1 gate-script compiler
    # Phase 5: wazero-CVE scanning (plan.md risk mitigation) + hand-authoring
    # / testing .wasm fixtures (quickstart.md uses wat2wasm).
    govulncheck
    wabt
  ];

  # PostgreSQL with pgvector for local development
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    extensions = extensions: [ extensions.pgvector ];
    initialDatabases = [{ name = "tendant"; }];
    listen_addresses = "127.0.0.1";
  };

  env = {
    GOPATH = "${config.env.DEVENV_STATE}/go";
    GOCACHE = "${config.env.DEVENV_STATE}/go-cache";
    GOMODCACHE = "${config.env.DEVENV_STATE}/go-mod-cache";
    DATABASE_URL = "postgres://127.0.0.1:5432/tendant?sslmode=disable";
  };

  dotenv.enable = true;

  enterShell = ''
    echo "tendant dev shell"
    echo "Go $(go version | cut -d' ' -f3)"
    echo "Dart $(dart --version 2>&1 | head -1)"
    echo "Node $(node --version 2>/dev/null)  ·  npm $(npm --version 2>/dev/null)"
    echo "Rust $(rustc --version 2>/dev/null | cut -d' ' -f2) (targets: wasm32-unknown-unknown)"
  '';

  git-hooks.hooks = {
    gofmt.enable = true;
    govet.enable = true;
  };
}
