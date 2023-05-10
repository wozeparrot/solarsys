{
  description = "woze's nix systems";

  inputs = {
    # nixpkgs
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs = {
      nixpkgs.follows = "nixpkgs";
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

    zigf.url = "github:mitchellh/zig-overlay";
    zigf.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    zls.url = "github:zigtools/zls";
    zls.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
      zig-overlay.follows = "zigf";
    };

    stylix.url = "github:danth/stylix";
    stylix.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprpicker.url = "github:hyprwm/hyprpicker";

    xdph.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    webcord.url = "github:fufexan/webcord-flake";

    nom.url = "github:maralorn/nix-output-monitor";
    nom.inputs = {
      flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    master,
    home-manager,
    flake-utils,
    ...
  }: let
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
          substituters = ["https://nix-gaming.cachix.org"];
          trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
        };
      };
      zigf = {
        inherit (inputs.zigf) packages;
      };
      zls = {
        inherit (inputs.zls) packages;
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
      hyprland-contrib = {
        inherit (inputs.hyprland-contrib) packages;
      };
      hyprpicker = {
        inherit (inputs.hyprpicker) packages;
      };
      xdph = {
        inherit (inputs.xdph) packages;
      };
      nixpkgs-wayland = {
        inherit (inputs.nixpkgs-wayland) packages;
        cache = {
          substituters = ["https://nixpkgs-wayland.cachix.org"];
          trusted-public-keys = ["nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="];
        };
      };
      webcord = {
        inherit (inputs.webcord) packages;
        cache = {
          substituters = ["https://webcord.cachix.org"];
          trusted-public-keys = ["webcord.cachix.org-1:l555jqOZGHd2C9+vS8ccdh8FhqnGe8L78QrHNn+EFEs="];
        };
      };
      nom = {
        inherit (inputs.nom) packages;
      };
    };

    overlay = let
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

    configNixpkgs' = extraOverlays: system: (
      import nixpkgs
      {
        inherit system;
        config.allowUnfree = true;
        overlays =
          [
            (
              _: _: {
                master = import master {
                  inherit system;
                  config.allowUnfree = true;
                };
              }
            )
          ]
          ++ overlay
          ++ (nixpkgs.lib.mapAttrsToList (_: v: v.overlay) (nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "overlay") external))
          ++ extraOverlays;
      }
      // nixpkgs.lib.mapAttrs (_: v: v.packages."${system}") (nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "packages") external)
    );
    configNixpkgs = configNixpkgs' [];
  in
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ]
    (
      system: let
        pkgs = configNixpkgs system;

        solarsys = pkgs.stdenv.mkDerivation {
          pname = "solarsys";
          version = "0.1.0";

          src = ./solarsys;

          nativeBuildInputs = with pkgs; [installShellFiles];

          installPhase = ''
            mkdir -p $out/bin/
            install -D ss $out/bin/
            install -D ssk $out/bin/
            install -D solarsys-remote.sh $out/bin/

            # install completions
            installShellCompletion completions/ss.fish
          '';
        };
      in {
        packages = pkgs;

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            git
            jq
            rsync
            rnix-lsp
            nvd
            nom.default
            shellcheck

            fish

            solarsys
          ];
        };
      }
    )
    // {
      solar-system = {};

      planets = let
        makeModules' = planet: pkgs: hostFile: [
          (
            {lib, ...}: {
              imports = [
                ./common/modules/solarsys
              ];

              solarsys.planet = planet;
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;

              nixpkgs.pkgs = pkgs;

              # build nix caches from external
              nix.settings = nixpkgs.lib.mapAttrs (_: nixpkgs.lib.flatten) (nixpkgs.lib.zipAttrs (nixpkgs.lib.attrValues (nixpkgs.lib.mapAttrs (_: v: v.cache) (nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "cache") external))));

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
      in rec {
        desktops = let
          makeModules = pkgs: hostFile:
            [
              home-manager.nixosModules.home-manager
              external.stylix.modules.stylix
            ]
            ++ makeModules' "desktops" pkgs hostFile;
        in {
          moons = {
            # woztop = let
            #   system = "x86_64-linux";
            #   pkgs = configNixpkgs system;
            # in {
            #   trajectory = "";
            #   orbits = [];
            #
            #   core = nixpkgs.lib.nixosSystem {
            #     inherit system specialArgs;
            #     modules = makeModules pkgs ./planets/desktops/woztop/host.nix;
            #   };
            # };
            woztop-horizon = let
              system = "x86_64-linux";
              pkgs = configNixpkgs system;
            in {
              trajectory = "";
              orbits = [];

              core = nixpkgs.lib.nixosSystem {
                inherit system specialArgs;
                modules = makeModules pkgs ./planets/desktops/woztop-horizon/host.nix;
              };
            };
          };
        };

        taurus = let
          makeModules = pkgs: hostFile:
            [
              (_: {
                solarsys.moons = taurus.moons;
              })
            ]
            ++ makeModules' "taurus" pkgs hostFile;
        in {
          moons = {
            amateru = let
              system = "aarch64-linux";
              pkgs =
                configNixpkgs' [
                  (final: prev: {
                    makeModulesClosure = x:
                      prev.makeModulesClosure (x // {allowMissing = true;});
                  })
                ]
                system;
            in {
              trajectory = {
                host = "192.168.0.11";
                port = 22;
              };
              orbits = ["nas"];
              satellites = {
                wg_private = {
                  path = "./satellites/taurus/amateru/wg_private";
                  destination = "/keys/wg_private";
                };
                wgam_gossip_secret = {
                  path = "./satellites/common/wgam_gossip_secret";
                  destination = "/keys/wgam_gossip_secret";
                };
                grafana_secret_key = {
                  path = "./satellites/taurus/amateru/grafana_secret_key";
                  destination = "/keys/grafana_secret_key";
                };
              };

              core = nixpkgs.lib.nixosSystem {
                inherit system specialArgs;
                modules = makeModules pkgs ./planets/taurus/amateru/host.nix;
              };
            };
            arion = let
              system = "aarch64-linux";
              pkgs =
                configNixpkgs' [
                  (final: prev: {
                    makeModulesClosure = x:
                      prev.makeModulesClosure (x // {allowMissing = true;});
                  })
                ]
                system;
            in {
              trajectory = {
                host = "192.168.0.194";
                port = 22;
              };
              orbits = ["runner"];
              satellites = {
                wg_private = {
                  path = "./satellites/taurus/arion/wg_private";
                  destination = "/keys/wg_private";
                };
                wgam_gossip_secret = {
                  path = "./satellites/common/wgam_gossip_secret";
                  destination = "/keys/wgam_gossip_secret";
                };
                nextcloud_adminpass = {
                  path = "./satellites/taurus/arion/nextcloud_adminpass";
                  destination = "/keys/nextcloud_adminpass";
                  chown = "999:999";
                };
              };

              core = nixpkgs.lib.nixosSystem {
                inherit system specialArgs;
                modules = makeModules pkgs ./planets/taurus/arion/host.nix;
              };
            };
            wangshu = let
              system = "x86_64-linux";
              pkgs = configNixpkgs system;
            in {
              trajectory = {
                host = "192.168.0.221";
                port = 22;
              };
              orbits = ["runner"];
              satellites = {
                wg_private = {
                  path = "./satellites/taurus/wangshu/wg_private";
                  destination = "/keys/wg_private";
                };
              };

              core = nixpkgs.lib.nixosSystem {
                inherit system specialArgs;
                modules = makeModules pkgs ./planets/taurus/wangshu/host.nix;
              };
            };
            veles = let
              system = "x86_64-linux";
              pkgs = configNixpkgs system;
            in {
              trajectory = {
                host = "192.168.0.243";
                port = 22;
              };
              orbits = ["runner"];
              satellites = {
                wg_private = {
                  path = "./satellites/taurus/veles/wg_private";
                  destination = "/keys/wg_private";
                };
                wozey_token = {
                  path = "./satellites/taurus/veles/wozey_token";
                  destination = "/var/lib/wozey/.token";
                };
              };

              core = nixpkgs.lib.nixosSystem {
                inherit system specialArgs;
                modules = makeModules pkgs ./planets/taurus/veles/host.nix;
              };
            };
          };
        };
      };
    };
}
