# NixOS module exposing the tendant API server as a systemd service.
#
# Secrets are delivered via systemd LoadCredential and read by the binary
# directly from $CREDENTIALS_DIRECTORY (see internal/secret.Getenv), so nothing
# sensitive lands in the Nix store or the unit's literal environment.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.tendant;

  # Local-socket DSN used when enableLocalPostgres is on and the operator has
  # not supplied their own databaseUrl.
  localDSN = "postgres:///tendant?host=/run/postgresql";

  settingType = lib.types.oneOf [ lib.types.str lib.types.int lib.types.bool ];
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
      description = "Listen address, mapped to HTTP_ADDR.";
    };

    databaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "postgres://tendant@db.internal:5432/tendant?sslmode=require";
      description = ''
        PostgreSQL DSN, mapped to DATABASE_URL. Required unless
        enableLocalPostgres is true. For a DSN that embeds a password, prefer
        delivering it as a credential (credentials."DATABASE_URL") so it stays
        out of the Nix store; in that case leave this null.
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
      type = lib.types.attrsOf (lib.types.nullOr settingType);
      default = { };
      example = lib.literalExpression ''
        {
          TENDANT_OVERSEER_PROVIDER = "anthropic";
          TENDANT_OVERSEER_MODEL_ID = "claude-sonnet-4-6";
          TENDANT_CALIBRATION_RATIO = "0.90";
          TENDANT_GATESCRIPT_RUNNER = "wazero";
        }
      '';
      description = ''
        Extra TENDANT_* (and other) environment variables passed verbatim to the
        service. Use this for every non-secret knob: overseer, gate-script,
        calibration, intake, and budget settings. A null value drops the entry.
        Do NOT put secrets here (they would land in the Nix store) — use
        credentials instead.
      '';
    };

    credentials = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      example = lib.literalExpression ''
        {
          TENDANT_CREDENTIALS_KEY = "/run/secrets/tendant-credentials-key";
          TENDANT_SETUP_SECRET = "/run/secrets/tendant-setup-secret";
          TENDANT_OVERSEER_ANTHROPIC_API_KEY = "/run/secrets/anthropic-key";
        }
      '';
      description = ''
        Secret name → file path. Each becomes a systemd LoadCredential entry;
        the binary reads it from $CREDENTIALS_DIRECTORY/<name> via secret.Getenv.
        Names MUST match the environment variable the binary expects, e.g.
        TENDANT_CREDENTIALS_KEY, TENDANT_SETUP_SECRET,
        TENDANT_OVERSEER_ANTHROPIC_API_KEY, TENDANT_OVERSEER_OPENAI_API_KEY,
        TENDANT_GMAIL_CLIENT_SECRET, or DATABASE_URL.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.databaseUrl != null || cfg.enableLocalPostgres
        || cfg.credentials ? "DATABASE_URL";
      message = "services.tendant: set databaseUrl, enable enableLocalPostgres, or provide a DATABASE_URL credential.";
    }];

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

      # Literal (non-secret) environment. DATABASE_URL is set here only when not
      # delivered as a credential, so the credential-file path always wins.
      environment = {
        HTTP_ADDR = cfg.httpAddr;
      }
      // lib.optionalAttrs (!(cfg.credentials ? "DATABASE_URL")) (
        if cfg.databaseUrl != null then { DATABASE_URL = cfg.databaseUrl; }
        else lib.optionalAttrs cfg.enableLocalPostgres { DATABASE_URL = localDSN; }
      )
      // lib.mapAttrs (_: toString) (lib.filterAttrs (_: v: v != null) cfg.settings);

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve";
        User = cfg.user;
        Group = cfg.group;
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
