# Linux desktop build of the tendant operator app (Flutter Linux/GTK).
#
# Sibling to nix/webui.nix but targets the GTK desktop embedder instead of the
# web one. The Flutter `linux/` scaffolding lives in apps/mobile/linux; the only
# plugin with a Linux implementation is flutter_secure_storage_linux (libsecret
# + jsoncpp via pkg-config). The Firebase push plugins have no Linux platform
# code, so Flutter omits them from the plugin registrant — the build succeeds
# and the app falls back to its stub providers at runtime (no push on desktop).
{
  lib,
  flutter,
  libsecret,
  jsoncpp,
}:

flutter.buildFlutterApplication {
  pname = "tendant-desktop";
  version = "0.1.0";

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

  targetFlutterPlatform = "linux";

  # flutter_secure_storage_linux's CMake does pkg_check_modules for these.
  # gtk3 is propagated by the flutter wrapper, so it is not listed here.
  buildInputs = [
    libsecret
    jsoncpp
  ];

  # flutter_secure_storage_linux trips -Werror on a deprecated literal operator
  # under recent toolchains. https://github.com/juliansteenbakker/flutter_secure_storage/issues/965
  env.CXXFLAGS = "-Wno-deprecated-literal-operator";

  meta = {
    description = "tendant operator desktop app (Flutter Linux/GTK)";
    # BINARY_NAME in apps/mobile/linux/CMakeLists.txt.
    mainProgram = "tendant_mobile";
    platforms = lib.platforms.linux;
  };
}
