{
  description = "woze's nix system";

  inputs = {
    # nixpkgs
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";

    # flake stuff
    colmena.url = "github:zhaofengli/colmena";
    flake-utils.url = "github:numtide/flake-utils";

    # overlays
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, master, home-manager, colmena, flake-utils, ... }:
    let
      overlays =
        let
          overlayDir = ./common/overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (builtins.attrNames (builtins.readDir overlayDir));
          pathsToImportedAttrs = paths:
            (values: f: builtins.listToAttrs (map f values)) paths (path: {
              name = nixpkgs.lib.removeSuffix ".nix" (baseNameOf path);
              value = import path;
            });
        in
        (builtins.attrValues (pathsToImportedAttrs overlayPaths)) ++ [
          inputs.neovim-nightly-overlay.overlay
        ];
    in
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ] (system: let
      pkgs = import nixpkgs { inherit system; };
      myColmena = import colmena { inherit pkgs; };
    in {
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          git
          myColmena
        ];
      };
    }) // {
      colmena = let
        configNixpkgs = system: (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (final: prev: {
              mpkgs = import master {
                inherit system;
                config.allowUnfree = true;
              };
            })
          ] ++ overlays;
        });

        makeDesktopModules = hostFile: [
          home-manager.nixosModules.home-manager
          ({ ... }: {
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          })
          hostFile
        ];
      in {
        meta = {
          inherit nixpkgs;
        };

        # --- node declarations ---
        # local deploy nodes
        woztop = {
          # nixpkgs = configNixpkgs "x86_64-linux";

          deployment = {
            allowLocalDeployment = true;

            targetHost = null;
          };
        # } // nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   modules = makeDesktopModules ./hosts/woztop/host.nix;
        };
      };
    };
}
