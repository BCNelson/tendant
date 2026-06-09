{ pkgs, lib, config, ... }:

{
  devenv.root =
    let
      devenvRoot = builtins.getEnv "DEVENV_ROOT";
    in
    if devenvRoot != "" then devenvRoot else builtins.toString ./.;

  languages.go.enable = true;
  languages.go.package = pkgs.go_1_26;

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

  # Android SDK + Flutter for `flutter build apk` (apps/mobile android/ target)
  # and the desktop/web targets. `flutter.enable = true` is the standard devenv
  # way to provision Flutter: it brings the Flutter SDK (with dart), wires it to
  # the Android SDK this module installs, AND sets up the Linux desktop build +
  # runtime environment (CMake/Ninja/GTK toolchain and the GTK XDG_DATA_DIRS the
  # built app needs at runtime for window decorations/themes). The module
  # accepts licenses, defaults java.jdk to JDK 17 (matching AGP 8.11), and sets
  # ANDROID_HOME + the aapt2 GRADLE_OPTS override needed on Nix.
  android = {
    enable = true;
    flutter.enable = true;
    # 36 = Flutter 3.41.6 compileSdk/targetSdk; 35 is needed by a plugin's `:jni`
    # subproject; 34 kept for older plugin compileSdk floors.
    platforms.version = [ "36" "35" "34" ];
    buildTools.version = [ "35.0.0" ];
    # NDK is required: the project's android/app/build.gradle sets
    # `ndkVersion = flutter.ndkVersion` and a plugin triggers an NDK build, so
    # Gradle needs NDK 28.2.13676358 present — otherwise it tries (and fails) to
    # auto-install into the read-only Nix SDK.
    ndk.enable = true;
    ndk.version = [ "28.2.13676358" ]; # = flutter.ndkVersion (Flutter 3.41.6)
    emulator.enable = false;
    systemImages.enable = false;
    googleAPIs.enable = false;
  };

  packages = with pkgs; [
    gotools
    golangci-lint
    delve
    git
    just
    sqlc
    goose
    # flutter_secure_storage_linux links against libsecret at runtime.
    libsecret
    assemblyscript # `asc` — Tier-1 gate-script compiler
    # Phase 5: wazero-CVE scanning (plan.md risk mitigation) + hand-authoring
    # / testing .wasm fixtures (quickstart.md uses wat2wasm).
    govulncheck
    wabt
    air # live-reload for the Go core (see .air.toml + processes.tendant below)
  ];

  # PostgreSQL with pgvector for local development
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    extensions = extensions: [ extensions.pgvector ];
    initialDatabases = [{ name = "tendant"; }];
    listen_addresses = "127.0.0.1";
  };

  # The Go core as a managed process with live reload. `devenv up` starts
  # Postgres + this; air (.air.toml) rebuilds + restarts on .go changes and runs
  # the server with the local-dev config (Ollama overseer + dev password).
  processes.tendant = {
    exec = "air -c .air.toml";
    process-compose = {
      working_dir = config.devenv.root;
      # Wait for Postgres to pass its readiness probe before the server migrates.
      depends_on.postgres.condition = "process_healthy";
      availability = {
        restart = "on_failure";
        max_restarts = 3;
      };
    };
  };

  env = {
    GOPATH = "${config.env.DEVENV_STATE}/go";
    GOCACHE = "${config.env.DEVENV_STATE}/go-cache";
    GOMODCACHE = "${config.env.DEVENV_STATE}/go-mod-cache";
    DATABASE_URL = "postgres://127.0.0.1:5432/tendant?sslmode=disable";
    # Point the Flutter client (native/desktop) at the locally-served core
    # (`devenv up` runs it on :8080). The app's ServerAddressResolver reads
    # TENDANT_SERVER_URL as a runtime override, so a dev shell skips the
    # server-address screen entirely. Web builds ignore this (they use the
    # serving origin); override per-shell to target a remote core.
    TENDANT_SERVER_URL = "http://localhost:8080";
    # The Android emulator runs on the virtual device, so it can NOT inherit the
    # shell env above and can NOT see the host's `localhost` — it reaches the
    # host at the QEMU loopback alias 10.0.2.2. `just app-android` bakes this in
    # at build time via --dart-define (the app's build-time override channel).
    # (Genymotion uses 10.0.3.2; a physical device needs the host's LAN IP —
    # override TENDANT_ANDROID_SERVER_URL per-shell for those.)
    TENDANT_ANDROID_SERVER_URL = "http://10.0.2.2:8080";
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
    # Pin the go-based hooks to the SAME toolchain as languages.go.package so
    # they can never drift from the shell's go again. git-hooks.nix otherwise
    # defaults these to pkgs.go independently; if that ever differs from
    # languages.go, the hook's `go` driver invokes a mismatched compile tool via
    # the exported GOROOT and fails ("version goX does not match go tool goY").
    gofmt.package = config.languages.go.package;
    govet.package = config.languages.go.package;
  };

  # Expose process-compose's built-in control tools (pc_process_list,
  # pc_process_start, pc_process_stop, pc_process_logs) over SSE while
  # `devenv up` is running. Paired with the .mcp.json "process-compose" entry.
  process.managers.process-compose.settings.mcp_server = {
    host = "127.0.0.1";
    port = 3011;
    expose_control_tools = true;
  };
}
