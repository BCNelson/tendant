# buildGoModule derivation for the tendant API server.
#
# Mirrors the multi-stage Dockerfile's build step: a static (CGO off) binary.
# The repo is a Go workspace (go.work → ./db + ./services/api), but `go mod
# vendor` refuses to run in workspace mode. services/api/go.mod carries a
# `replace github.com/bcnelson/tendant/db => ../../db`, so we build the single
# services/api module with the workspace disabled — db resolves through the
# replace directive against ./db, which is present in src.
#
# When `webui` (the Flutter web bundle from ./webui.nix) is supplied, it is
# staged into internal/webui/dist before `go build` so the //go:embed all:dist
# directive bakes the real UI into the binary — the same artifact the
# Dockerfile produces. With `webui = null` the server falls back to the
# built-in placeholder page (a fast, web-free build).
{ lib, buildGoModule, version ? "dev", webui ? null }:

buildGoModule {
  pname = "tendant";
  inherit version;

  # Whole repo so the `../../db` replace target is present in the source tree.
  src = lib.cleanSource ../.;

  modRoot = "services/api";

  # Drop the workspace so vendoring sees a single module (the replace handles db).
  postPatch = ''
    rm -f go.work go.work.sum
  '';
  env.GOWORK = "off";

  # Stage the Flutter web bundle into the //go:embed dist directory. Runs in
  # postConfigure (cwd = modRoot = services/api, vendor already in place) which
  # — unlike preBuild/postPatch — is NOT inherited by the goModules vendoring
  # FOD, so vendoring never forces a Flutter build and the vendorHash is
  # unaffected.
  postConfigure = lib.optionalString (webui != null) ''
    rm -rf internal/webui/dist
    mkdir -p internal/webui/dist
    cp -r ${webui}/. internal/webui/dist/
    chmod -R u+w internal/webui/dist
  '';

  # Replace lib.fakeHash with the value Nix reports on first build (the "got:"
  # hash in the mismatch error).
  vendorHash = "sha256-485aEmGS5QMfdbIVzunuFOHv/M7AkpGbx/PigLe7jLk=";

  # Static build, matching the Dockerfile (distroless-static compatible).
  env.CGO_ENABLED = "0";

  subPackages = [ "cmd/tendant" ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=${version}"
    "-X"
    "main.commit=nix"
    "-X"
    "main.buildDate=unknown"
  ];

  # The Go test suite needs testcontainers-go + Docker, which is unavailable in
  # the Nix sandbox. Tests run in CI / the devenv shell instead.
  doCheck = false;

  meta = {
    description = "tendant API server";
    mainProgram = "tendant";
    platforms = lib.platforms.linux;
  };
}
