{
  description = "tendant - Development Environment";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    # Required by languages.rust.channel ("stable") for the wasm32 cross-target
    # used to build the Rust gate-script SDK (sdks/gate-sdk-rust).
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      # Reflect the building revision in the binary's main.version.
      version = self.shortRev or self.dirtyShortRev or "dev";
    in
    {
      # Build variants:
      #   nix build .#tendant         → API server with the Flutter web UI embedded (default).
      #   nix build .#tendant-server  → API server only, no bundled UI (serves placeholder).
      #   nix build .#webui           → the standalone Flutter web bundle.
      #   nix build .#tendant-desktop → the Flutter Linux/GTK desktop app.
      packages = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          webui = pkgs.callPackage ./nix/webui.nix { };
          tendant = pkgs.callPackage ./nix/package.nix {
            inherit version webui;
          };
          tendant-server = pkgs.callPackage ./nix/package.nix {
            inherit version;
            webui = null;
          };
          tendant-desktop = pkgs.callPackage ./nix/desktop.nix { };
        in
        {
          inherit
            tendant
            tendant-server
            webui
            tendant-desktop
            ;
          default = tendant;
        }
      );

      # Overlay so consumers get pkgs.tendant (web UI embedded) and the variants.
      overlays.default = final: _prev: {
        tendant-webui = final.callPackage ./nix/webui.nix { };
        tendant-desktop = final.callPackage ./nix/desktop.nix { };
        tendant-server = final.callPackage ./nix/package.nix {
          inherit version;
          webui = null;
        };
        tendant = final.callPackage ./nix/package.nix {
          inherit version;
          webui = final.callPackage ./nix/webui.nix { };
        };
      };

      # NixOS module: services.tendant. Defaults its package to a build from this
      # repo; override services.tendant.package with the flake's package output
      # for a pinned, version-stamped build.
      nixosModules.tendant = import ./nix/module.nix;
      nixosModules.default = self.nixosModules.tendant;

      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ./devenv.nix
            ];
          };
        }
      );
    };
}
