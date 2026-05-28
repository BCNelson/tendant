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

  packages = with pkgs; [
    gotools
    golangci-lint
    delve
    git
    just
    sqlc
    goose
    flutter
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
  '';

  git-hooks.hooks = {
    gofmt.enable = true;
    govet.enable = true;
  };
}
