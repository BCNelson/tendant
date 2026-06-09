# Flutter web bundle for the tendant operator UI.
#
# Mirrors the Dockerfile's `webbuilder` stage: `flutter build web --release`
# with the base href at `/`. The output ($out) is the contents of
# apps/mobile/build/web — the plain HTML/JS/wasm SPA that nix/package.nix
# embeds into the Go binary at services/api/internal/webui/dist.
#
# Dependencies are pure hosted pub.dev packages (no git/path deps), so
# `autoPubspecLock` fetches each one using the sha256 already pinned in
# apps/mobile/pubspec.lock — there is no separate vendor hash to maintain.
{ lib, flutter }:

flutter.buildFlutterApplication {
  pname = "tendant-webui";
  version = "0.1.0";

  # Exclude local build leftovers so a stale apps/mobile/build or .dart_tool
  # in the working tree never leaks into the source.
  src = lib.cleanSourceWith {
    src = lib.cleanSource ../apps/mobile;
    filter =
      path: _type:
      let
        base = baseNameOf path;
      in
      base != "build" && base != ".dart_tool";
  };

  autoPubspecLock = ../apps/mobile/pubspec.lock;

  targetFlutterPlatform = "web";

  # Match the Dockerfile: serve from the site root.
  flutterBuildFlags = [ "--base-href=/" ];

  meta = {
    description = "tendant operator web UI (Flutter web bundle)";
    platforms = lib.platforms.linux;
  };
}
