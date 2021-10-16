{
  description = "woze's nix systems";

  inputs = {
    # nixpkgs
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # flake stuff
    flake-utils.url = "github:numtide/flake-utils";

    # overlays
    aninarr.url = "git+ssh://git@github.com/wozeparrot/aninarr.git?ref=main";
    aninarr.inputs.nixpkgs.follows = "nixpkgs";
    aninarr.inputs.flake-utils.follows = "flake-utils";

    wozey.url = "git+ssh://git@github.com/wozeparrot/wozey.service.git?ref=main";
    wozey.inputs.nixpkgs.follows = "nixpkgs";
    wozey.inputs.flake-utils.follows = "flake-utils";
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
          inputs.aninarr.overlay
          inputs.wozey.overlay
        ];
    in
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ]
      (
        system:
        let
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
        solar-system = { };

        planets =
          let
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
            desktops =
              let
                makeDesktopModules = pkgs: hostFile: [
                  home-manager.nixosModules.home-manager
                ] ++ makeModules pkgs hostFile;
              in
              {
                moons = {
                  woztop =
                    let
                      system = "x86_64-linux";
                      pkgs = configNixpkgs system;
                    in
                    {
                      trajectory = "";
                      orbits = [ ];

                      core = nixpkgs.lib.nixosSystem {
                        inherit system specialArgs;
                        modules = makeDesktopModules pkgs ./planets/desktops/woztop/host.nix;
                      };
                    };
                };
              };

            infra0 = {
              moons = {
                nas0 =
                  let
                    system = "aarch64-linux";
                    pkgs = configNixpkgs system;
                  in
                  {
                    trajectory = {
                      host = "fdbe:ef11:2358:1321::1";
                      port = 22;
                    };
                    orbits = [ "nas" ];
                    satellites.wg_private = {
                      path = "./satellites/infra0/nas0/wg_private";
                      destination = "/keys/wg_private";
                    };

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeModules pkgs ./planets/infra0/nas0/host.nix;
                    };
                  };
                x86runner0 =
                  let
                    system = "x86_64-linux";
                    pkgs = configNixpkgs system;
                  in
                  {
                    trajectory = {
                      host = "192.168.0.221";
                      port = 22;
                    };
                    orbits = [ "runners" ];
                    satellites.wozey_token = {
                      path = "./satellites/infra0/x86runner0/wozey_token";
                      destination = "/var/lib/wozey/.token";
                    };

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeModules pkgs ./planets/infra0/x86runner0/host.nix;
                    };
                  };
              };
            };
          };
      }
    );
}
