{
  description = "woze's nix systems";

  inputs = {
    # nixpkgs
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";

    # flake stuff
    flake-utils.url = "github:numtide/flake-utils";

    # overlays
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, master, home-manager, flake-utils, ... }:
    let
      overlays =
        let
          overlayDir = ./common/overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (builtins.attrNames (builtins.readDir overlayDir));
          pathsToImportedAttrs = paths:
            (values: f: builtins.listToAttrs (map f values)) paths (
              path: {
                name = nixpkgs.lib.removeSuffix ".nix" (baseNameOf path);
                value = import path;
              }
            );
        in
          (builtins.attrValues (pathsToImportedAttrs overlayPaths)) ++ [
            inputs.neovim-nightly-overlay.overlay
          ];
    in
      flake-utils.lib.eachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ] (
        system: let
          pkgs = import nixpkgs { inherit system; };
        in
          {
            devShell = pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                git
                jq
                rsync
              ];
            };
          }
      ) // (
        let
          configNixpkgs = system: (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                (
                  final: prev: {
                    mpkgs = import master {
                      inherit system;
                      config.allowUnfree = true;
                    };
                  }
                )
              ] ++ overlays;
            }
          );
        in
          {
            solar-system = {};

            planets = let
              makeModules = pkgs: hostFile: [
                (
                  { lib, ... }: {
                    system.configurationRevision = lib.mkIf (self ? rev) self.rev;

                    nixpkgs.config = pkgs.config;
                    nixpkgs.pkgs = pkgs;

                    _module.args = {
                      inherit inputs pkgs;
                    };
                  }
                )
                hostFile
              ];
              specialArgs = {
                inherit inputs;
              };
            in
              {
                desktops = let
                  makeDesktopModules = pkgs: hostFile: [
                    home-manager.nixosModules.home-manager
                  ] ++ makeModules pkgs hostFile;
                in
                  {
                    moons = {
                      woztop = let
                        system = "x86_64-linux";
                        pkgs = configNixpkgs system;
                      in
                        {
                          trajectory = "";
                          orbits = [];

                          core = nixpkgs.lib.nixosSystem {
                            inherit system specialArgs;
                            modules = makeDesktopModules pkgs ./planets/desktops/woztop/host.nix;
                          };
                        };
                    };
                  };

                infra0 = {
                  moons = {
                    anime_nas = let
                      system = "aarch64-linux";
                      pkgs = configNixpkgs system;
                    in
                      {
                        trajectory = {
                          host = "192.168.0.131";
                          port = 21;
                        };
                        orbits = [ "nas" ];

                        core = nixpkgs.lib.nixosSystem {
                          inherit system specialArgs;
                          modules = makeModules pkgs ./planets/infra0/anime_nas/host.nix;
                        };
                      };
                  };
                };
              };
          }
      );
}
