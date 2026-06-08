# NixOS module exposing the tendant API server as a systemd service.
#
# Configuration is file-based: the `settings` option is rendered to a real
# tendant.toml at /etc/tendant/tendant.toml and passed via `serve --config`.
# This is the only way to express the file-only catalogs — [[llm_connections]],
# [[agents]], [[tools]], [[connectors]] — which have no flat-env encoding.
#
# Secrets are delivered via systemd LoadCredential and read by the binary
# directly from $CREDENTIALS_DIRECTORY (see internal/secret.Getenv), so nothing
# sensitive lands in the Nix store or the world-readable config file. Reference
# them from settings via the *_env fields (e.g. a connection's api_key_env),
# never as literals.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.tendant;

  # Local-socket DSN used when enableLocalPostgres is on and the operator has
  # not supplied their own databaseUrl.
  localDSN = "postgres:///tendant?host=/run/postgresql";

  tomlFormat = pkgs.formats.toml { };

  # The convenience httpAddr option is folded into the rendered TOML's
  # [server] section; an explicit settings.server.http_addr wins.
  mergedSettings = lib.recursiveUpdate {
    server.http_addr = cfg.httpAddr;
  } cfg.settings;

  configFile = tomlFormat.generate "tendant.toml" mergedSettings;
  configPath = "/etc/tendant/tendant.toml";
in
{
  options.services.tendant = {
    enable = lib.mkEnableOption "the tendant API server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The tendant package to run. Override with the flake's package for a pinned build.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "tendant";
      description = "User the service runs as (created unless overridden).";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "tendant";
      description = "Group the service runs as (created unless overridden).";
    };

    httpAddr = lib.mkOption {
      type = lib.types.str;
      default = ":8080";
      description = "Listen address, written to [server].http_addr in the generated tendant.toml.";
    };

    databaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "postgres://tendant@db.internal:5432/tendant?sslmode=require";
      description = ''
        PostgreSQL DSN, delivered as the DATABASE_URL environment variable
        (env > file, so it overrides any database.url in settings). Required
        unless enableLocalPostgres is true. For a DSN that embeds a password,
        prefer delivering it as a credential (credentials."DATABASE_URL") so it
        stays out of the Nix store; in that case leave this null.
      '';
    };

    enableLocalPostgres = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Provision a local PostgreSQL with the pgvector extension, create the
        tendant database + role, and default databaseUrl to a local socket DSN.
        For single-host deploys; leave off to point at an external database.
      '';
    };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          log.level = "info";
          gate.call_budget = 100;

          overseer = {
            connection = "claude";       # pick a connection defined below
            max_eval_per_task = 50;
          };

          # File-only catalog: define as many model endpoints as you like,
          # including several of the same provider. Secrets go in via
          # ''${env:NAME} or ''${file:PATH} interpolation — never inline a key.
          llm_connections = [
            {
              name = "claude";
              provider = "anthropic";
              model = "claude-sonnet-4-6";
              # ''${env:...} resolves from credentials (LoadCredential) or environmentFile.
              api_key = "\''${env:TENDANT_OVERSEER_ANTHROPIC_API_KEY}";
            }
            {
              name = "gpt";
              provider = "openai";
              model = "gpt-4.1-mini";
              # ''${file:...} reads a secret file directly (sops-nix / agenix).
              api_key = "\''${file:/run/secrets/openai-key}";
            }
            {
              name = "local-ollama";       # any OpenAI-compatible endpoint
              provider = "openai";
              base_url = "http://localhost:11434";
              model = "llama3.1";
            }
            {
              name = "bedrock-claude";
              provider = "bedrock";
              region = "us-east-1";
              model = "anthropic.claude-3-5-sonnet-20241022-v2:0";
              access_key_id = "\''${env:AWS_ACCESS_KEY_ID}";
              secret_access_key = "\''${file:/run/secrets/aws-secret}";
            }
          ];
        }
      '';
      description = ''
        Contents of tendant.toml, rendered to ${configPath} and passed to the
        binary via `serve --config`. Use nested attrs for [section] tables and
        lists of attrs for [[array]] catalogs (llm_connections, agents, tools,
        connectors). See docs/configuration-reference.md and tendant.example.toml
        for the full key set.

        Do NOT inline secrets — this file is world-readable in the Nix store.
        Reference them with interpolation instead:
          ''${env:NAME}    — env var NAME (also honors NAME_FILE and the systemd
                            CREDENTIALS_DIRECTORY drop, so it reads `credentials`
                            and `environmentFile` entries below)
          ''${file:PATH}   — contents of a secret file (sops-nix / agenix / k8s)
          ''${env:NAME:-default} — NAME, or default if unset
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/tendant.env";
      description = ''
        Optional systemd EnvironmentFile (KEY=value lines) exposed to the
        service. Its keys are resolvable from settings via ''${env:KEY} — the
        simplest way to deliver many model-connection secrets at once without a
        LoadCredential entry per key. Keep the file out of the Nix store
        (e.g. an sops-nix / agenix output path).
      '';
    };

    credentials = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      example = lib.literalExpression ''
        {
          TENDANT_CREDENTIALS_KEY = "/run/secrets/tendant-credentials-key";
          TENDANT_SETUP_SECRET = "/run/secrets/tendant-setup-secret";
          # Referenced from a connection's api_key_env:
          TENDANT_OVERSEER_ANTHROPIC_API_KEY = "/run/secrets/anthropic-key";
          OPENAI_API_KEY = "/run/secrets/openai-key";
        }
      '';
      description = ''
        Secret name → file path. Each becomes a systemd LoadCredential entry;
        the binary reads it from $CREDENTIALS_DIRECTORY/<name> via secret.Getenv.
        The name is what you reference from settings as ''${env:NAME} (for model
        connections), or the environment variable the binary expects directly,
        e.g. TENDANT_CREDENTIALS_KEY, TENDANT_SETUP_SECRET,
        TENDANT_GMAIL_CLIENT_SECRET, or DATABASE_URL. For bulk secrets prefer
        `environmentFile`; for direct paths use a ''${file:...} reference.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.databaseUrl != null || cfg.enableLocalPostgres
        || cfg.credentials ? "DATABASE_URL";
      message = "services.tendant: set databaseUrl, enable enableLocalPostgres, or provide a DATABASE_URL credential.";
    }];

    # Render the file-based config to a stable, inspectable path.
    environment.etc."tendant/tendant.toml".source = configFile;

    users.users = lib.mkIf (cfg.user == "tendant") {
      tendant = {
        isSystemUser = true;
        group = cfg.group;
      };
    };
    users.groups = lib.mkIf (cfg.group == "tendant") { tendant = { }; };

    services.postgresql = lib.mkIf cfg.enableLocalPostgres {
      enable = true;
      extensions = ps: [ ps.pgvector ];
      ensureDatabases = [ "tendant" ];
      ensureUsers = [{
        name = cfg.user;
        ensureDBOwnership = true;
      }];
    };

    systemd.services.tendant = {
      description = "tendant API server";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ]
        ++ lib.optional cfg.enableLocalPostgres "postgresql.service";
      requires = lib.optional cfg.enableLocalPostgres "postgresql.service";

      # DATABASE_URL is the one knob kept in the environment (secret DSN): it is
      # set here only when not delivered as a credential, so the credential-file
      # path always wins. Every other setting lives in the rendered config file.
      environment = lib.optionalAttrs (!(cfg.credentials ? "DATABASE_URL")) (
        if cfg.databaseUrl != null then { DATABASE_URL = cfg.databaseUrl; }
        else lib.optionalAttrs cfg.enableLocalPostgres { DATABASE_URL = localDSN; }
      );

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve --config ${configPath}";
        User = cfg.user;
        Group = cfg.group;
        # Bulk secrets resolvable via ${env:KEY} in the config file.
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        # Binary reads each secret from $CREDENTIALS_DIRECTORY/<name>.
        LoadCredential = lib.mapAttrsToList (name: path: "${name}:${path}") cfg.credentials;
        Restart = "on-failure";
        RestartSec = 5;

        # Hardening: the binary is static and only needs network + Postgres socket.
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      };
    };
  };
}
