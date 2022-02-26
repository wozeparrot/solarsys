{
  description = "woze's nix systems";

  inputs = {
    # nixpkgs
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";
    staging-next.url = "github:NixOS/nixpkgs/staging-next";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # flake stuff
    flake-utils.url = "github:numtide/flake-utils";

    # overlays + extra package sets
    aninarr.url = "git+ssh://git@github.com/wozeparrot/aninarr.git?ref=main";
    aninarr.inputs.nixpkgs.follows = "nixpkgs";
    aninarr.inputs.flake-utils.follows = "flake-utils";

    wozey.url = "git+ssh://git@github.com/wozeparrot/wozey.service.git?ref=main";
    wozey.inputs.nixpkgs.follows = "nixpkgs";
    wozey.inputs.flake-utils.follows = "flake-utils";

    nix-gaming.url = "github:fufexan/nix-gaming";
    # nix-gaming.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, master, staging-next, home-manager, flake-utils, ... }:
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
        ];
      external = {
        wozey = {
          packages = inputs.wozey.packages;
        };
        nix-gaming = {
          packages = inputs.nix-gaming.packages;
          cache = {
            substituters = [ "https://nix-gaming.cachix.org" ];
            trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
          };
        };
      };

      configNixpkgs = system: (
        import nixpkgs
          {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (
                final: prev: {
                  master = import master {
                    inherit system;
                    config.allowUnfree = true;
                  };
                  staging-next = import staging-next {
                    inherit system;
                    config.allowUnfree = true;
                  };
                }
              )
            ] ++ overlays;
          } // nixpkgs.lib.mapAttrs (n: v: v.packages."${system}") (nixpkgs.lib.filterAttrs (n: v: nixpkgs.lib.hasAttr "packages" v) external)
      );
    in
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ]
      (
        system:
        let
          pkgs = configNixpkgs system;
        in
        {
          legacyPackages = pkgs;

          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              git
              jq
              rsync
              rnix-lsp
            ];
          };
        }
      ) //
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

                # build nix caches from external
                nix.settings = nixpkgs.lib.mapAttrs (n: v: nixpkgs.lib.flatten v) (nixpkgs.lib.zipAttrs (nixpkgs.lib.attrValues (nixpkgs.lib.mapAttrs (n: v: v.cache) (nixpkgs.lib.filterAttrs (n: v: nixpkgs.lib.hasAttr "cache" v) external))));

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
                    host = "192.168.0.11";
                    port = 22;
                  };
                  orbits = [ "aarch64-build" "nas" ];
                  satellites = {
                    wg_private = {
                      path = "./satellites/infra0/nas0/wg_private";
                      destination = "/keys/wg_private";
                    };
                    dsvpn = {
                      path = "./satellites/common/dsvpn";
                      destination = "/keys/dsvpn";
                    };
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
                  orbits = [ "x86-build" "runners" ];
                  satellites = {
                    wg_private = {
                      path = "./satellites/infra0/x86runner0/wg_private";
                      destination = "/keys/wg_private";
                    };
                  };

                  core = nixpkgs.lib.nixosSystem {
                    inherit system specialArgs;
                    modules = makeModules pkgs ./planets/infra0/x86runner0/host.nix;
                  };
                };
              x86runner1 =
                let
                  system = "x86_64-linux";
                  pkgs = configNixpkgs system;
                in
                {
                  trajectory = {
                    host = "192.168.0.243";
                    port = 22;
                  };
                  orbits = [ "x86-build" "runners" ];
                  satellites = {
                    wg_private = {
                      path = "./satellites/infra0/x86runner1/wg_private";
                      destination = "/keys/wg_private";
                    };
                    wozey_token = {
                      path = "./satellites/infra0/x86runner1/wozey_token";
                      destination = "/var/lib/wozey/.token";
                    };
                    matrix_as_discord_env = {
                      path = "./satellites/infra0/x86runner1/matrix_as_discord_env";
                      destination = "/keys/matrix_as_discord_env";
                    };
                  };

                  core = nixpkgs.lib.nixosSystem {
                    inherit system specialArgs;
                    modules = makeModules pkgs ./planets/infra0/x86runner1/host.nix;
                  };
                };
            };
          };
        };
    };
}
