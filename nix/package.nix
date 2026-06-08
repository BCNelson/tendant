# buildGoModule derivation for the tendant API server.
#
# Mirrors the multi-stage Dockerfile's build step: a static (CGO off) binary.
# The repo is a Go workspace (go.work → ./db + ./services/api), but `go mod
# vendor` refuses to run in workspace mode. services/api/go.mod carries a
# `replace github.com/bcnelson/tendant/db => ../../db`, so we build the single
# services/api module with the workspace disabled — db resolves through the
# replace directive against ./db, which is present in src.
{ lib, buildGoModule, version ? "dev" }:

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

  # Replace lib.fakeHash with the value Nix reports on first build (the "got:"
  # hash in the mismatch error).
  vendorHash = "sha256-cf3clh7Ee6leC45xF3WkHtFYzgkFwpdyd9u4gklh7nI=";

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
