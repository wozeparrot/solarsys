{
  description = "woze's nix systems";

  inputs = {
    # nixpkgs
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";
    staging-next.url = "github:NixOS/nixpkgs/staging-next";
    wozepkgs.url = "github:wozeparrot/nixpkgs/seaweedfs";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs = {
      nixpkgs.follows = "nixpkgs";
      utils.follows = "flake-utils";
    };

    # flake stuff
    flake-utils.url = "github:numtide/flake-utils";

    # overlays + extra package sets + extra modules
    aninarr.url = "git+ssh://git@github.com/wozeparrot/aninarr.git?ref=main";
    aninarr.inputs = {
      # nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    wozey.url = "git+ssh://git@github.com/wozeparrot/wozey.service.git?ref=main";
    wozey.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    n2n.url = "git+ssh://git@github.com/wozeparrot/n2n-nix.git?ref=main";
    n2n.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs = {
      nixpkgs.follows = "nixpkgs";
      utils.follows = "flake-utils";
    };

    zigf.url = "github:mitchellh/zig-overlay";
    zigf.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    stylix.url = "github:danth/stylix";
    stylix.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprpicker.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    webcord.url = "github:fufexan/webcord-flake";
    webcord.inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, master, staging-next, wozepkgs, home-manager, flake-utils, ... }:
    let
      # external/third-party stuff
      external = {
        aninarr = {
          inherit (inputs.aninarr) packages;
        };
        wozey = {
          inherit (inputs.wozey) packages;
        };
        nix-gaming = {
          inherit (inputs.nix-gaming) packages;
          cache = {
            substituters = [ "https://nix-gaming.cachix.org" ];
            trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
          };
        };
        nix-ld = {
          modules = inputs.nix-ld.nixosModules;
        };
        zigf = {
          inherit (inputs.zigf) packages;
        };
        n2n = {
          inherit (inputs.n2n) packages;
        };
        stylix = {
          modules = inputs.stylix.nixosModules;
        };
        hyprland = {
          inherit (inputs.hyprland) packages;
        };
        hyprpicker = {
          inherit (inputs.hyprpicker) packages;
        };
        nixpkgs-wayland = {
          inherit (inputs.nixpkgs-wayland) packages;
        };
        webcord = {
          inherit (inputs.webcord) packages;
        };
      };

      overlay =
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
        builtins.attrValues (pathsToImportedAttrs overlayPaths);

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
                  wozepkgs = import wozepkgs {
                    inherit system;
                    config.allowUnfree = true;
                  };
                }
              )
            ] ++ overlay ++ (nixpkgs.lib.mapAttrsToList (n: v: v.overlay) (nixpkgs.lib.filterAttrs (n: nixpkgs.lib.hasAttr "overlay") external));
          } // nixpkgs.lib.mapAttrs (n: v: v.packages."${system}") (nixpkgs.lib.filterAttrs (n: nixpkgs.lib.hasAttr "packages") external)
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

          solarsys = pkgs.stdenv.mkDerivation {
            pname = "solarsys";
            version = "0.1.0";

            src = ./solarsys;

            installPhase = ''
              mkdir -p $out/bin/
              install -D ./ss $out/bin/
              install -D ./solarsys-remote.sh $out/bin/
            '';
          };
        in
        {
          packages = pkgs;

          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              git
              jq
              rsync
              rnix-lsp
              nvd

              fish

              solarsys
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

                nixpkgs.pkgs = pkgs;

                # build nix caches from external
                nix.settings = nixpkgs.lib.mapAttrs (n: nixpkgs.lib.flatten) (nixpkgs.lib.zipAttrs (nixpkgs.lib.attrValues (nixpkgs.lib.mapAttrs (n: v: v.cache) (nixpkgs.lib.filterAttrs (n: nixpkgs.lib.hasAttr "cache") external))));

                _module.args = {
                  inherit inputs;
                  pkgs = pkgs.lib.mkForce pkgs;
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
                external.nix-ld.modules.nix-ld
                external.stylix.modules.stylix
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
                woztop-horizon =
                  let
                    system = "x86_64-linux";
                    pkgs = configNixpkgs system;
                  in
                  {
                    trajectory = "";
                    orbits = [ ];

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeDesktopModules pkgs ./planets/desktops/woztop-horizon/host.nix;
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
                    n2n-supernode = {
                      path = "./satellites/infra0/nas0/n2n-supernode.conf";
                      destination = "/keys/n2n-supernode.conf";
                    };
                    n2n-community = {
                      path = "./satellites/infra0/nas0/n2n-community.list";
                      destination = "/keys/n2n-community.list";
                    };
                    n2n-edge = {
                      path = "./satellites/infra0/nas0/n2n-edge.conf";
                      destination = "/keys/n2n-edge.conf";
                    };
                  };

                  core = nixpkgs.lib.nixosSystem {
                    inherit system specialArgs;
                    modules = makeModules pkgs ./planets/infra0/nas0/host.nix;
                  };
                };
              nas1 =
                let
                  system = "aarch64-linux";
                  pkgs = configNixpkgs system;
                in
                {
                  trajectory = {
                    host = "192.168.0.214";
                    port = 22;
                  };
                  orbits = [ "aarch64-build" "nas" ];

                  core = nixpkgs.lib.nixosSystem {
                    inherit system specialArgs;
                    modules = makeModules pkgs ./planets/infra0/nas1/host.nix;
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
