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
    wozey.url = "github:wozeparrot/wozey.service";
    wozey.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    n2n.url = "github:wozeparrot/n2n-nix";
    n2n.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    zigf.url = "github:mitchellh/zig-overlay";
    zigf.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    zls.url = "github:zigtools/zls";
    zls.inputs = {
      nixpkgs.follows = "nixpkgs";
      zig-overlay.follows = "zigf";
    };

    stylix.url = "github:danth/stylix";
    stylix.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprpaper.url = "git+https://github.com/hyprwm/hyprpaper";
    hyprpaper.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";
    hyprcursor-phinger.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs = {
      hyprland.follows = "hyprland";
    };

    hyprpicker.url = "github:hyprwm/hyprpicker";

    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    waybar.url = "github:Alexays/Waybar";

    nom.url = "github:maralorn/nix-output-monitor";
    nom.inputs = {
      flake-utils.follows = "flake-utils";
    };

    nixd.url = "github:nix-community/nixd";

    ensky.url = "github:wozeparrot/ensky";
    ensky.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    seaweedfs.url = "github:wozeparrot/seaweedfs-nix";
    seaweedfs.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    jovian.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      master,
      home-manager,
      flake-utils,
      ...
    }:
    let
      # external/third-party stuff
      external = {
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
        chaotic = {
          packages = inputs.chaotic.legacyPackages;
          # cache = {
          #   substituters = [ "https://nyx.chaotic.cx" ];
          #   trusted-public-keys = [ "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" ];
          # };
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
        hyprland = {
          inherit (inputs.hyprland) packages;
        };
        hyprpaper = {
          inherit (inputs.hyprpaper) packages;
        };
        hyprcursor-phinger = {
          hm-modules = inputs.hyprcursor-phinger.homeManagerModules;
        };
        hyprland-contrib = {
          inherit (inputs.hyprland-contrib) packages;
        };
        hyprland-plugins = {
          inherit (inputs.hyprland-plugins) packages;
        };
        hyprpicker = {
          inherit (inputs.hyprpicker) packages;
        };
        hyprsplit = {
          inherit (inputs.hyprsplit) packages;
        };
        nixpkgs-wayland = {
          inherit (inputs.nixpkgs-wayland) packages;
          cache = {
            substituters = [ "https://nixpkgs-wayland.cachix.org" ];
            trusted-public-keys = [
              "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            ];
          };
        };
        waybar = {
          inherit (inputs.waybar) packages;
        };
        nom = {
          inherit (inputs.nom) packages;
        };
        nixd = {
          inherit (inputs.nixd) packages;
        };
        ensky = {
          inherit (inputs.ensky) packages;
          modules = inputs.ensky.nixosModules;
        };
        seaweedfs = {
          inherit (inputs.seaweedfs) packages;
        };
        jovian = {
          packages = inputs.jovian.legacyPackages;
        };
        nixvim = {
          hm-modules = inputs.nixvim.homeManagerModules;
        };
      };

      overlay =
        let
          overlayDir = ./common/overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (builtins.attrNames (builtins.readDir overlayDir));
          pathsToImportedAttrs =
            paths:
            (values: f: builtins.listToAttrs (map f values)) paths (path: {
              name = nixpkgs.lib.removeSuffix ".nix" (baseNameOf path);
              value = import path;
            });
        in
        builtins.attrValues (pathsToImportedAttrs overlayPaths);

      configNixpkgs' =
        extraOverlays: system:
        (
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (_: _: {
                master = import master {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ]
            ++ overlay
            ++ (nixpkgs.lib.mapAttrsToList (_: v: v.overlays) (
              nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "overlays") external
            ))
            ++ extraOverlays;
          }
          // nixpkgs.lib.mapAttrs (_: v: v.packages."${system}") (
            nixpkgs.lib.filterAttrs (_: p: (builtins.hasAttr "${system}" p.packages)) (
              nixpkgs.lib.filterAttrs (_: builtins.hasAttr "packages") external
            )
          )
        );
      configNixpkgs = configNixpkgs' [ ];
    in
    flake-utils.lib.eachSystem
      [
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

            nativeBuildInputs = with pkgs; [ installShellFiles ];

            installPhase = ''
              mkdir -p $out/bin/
              cp *.bash $out/bin/

              install -D ss $out/bin/
              install -D ssk $out/bin/
              install -D solarsys-remote.sh $out/bin/

              # patch the completion script to use the full path to solarsys
              sed -i "s|ss json|$out/bin/ss json|g" completions/ss.fish

              # install completions
              installShellCompletion completions/ss.fish
            '';
          };
        in
        {
          packages = pkgs;

          devShell = pkgs.mkShell {
            nativeBuildInputs =
              (with pkgs; [
                fzf
                git
                jq
                nix-tree
                nom.default
                nvd
                rsync
                shellcheck
              ])
              ++ [ solarsys ];
          };
        }
      )
    // {
      inherit (nixpkgs) lib;
    }
    // {
      solar-system = { };

      planets =
        let
          makeModules' = planet: pkgs: hostFile: [
            (
              { lib, ... }:
              {
                # import external modules
                imports = [
                  ./common/modules/solarsys
                ]
                ++ (nixpkgs.lib.mapAttrsToList (n: v: v.modules."${n}") (
                  nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "modules") external
                ));

                solarsys.planet = planet;
                system.configurationRevision = lib.mkIf (self ? rev) self.rev;

                nixpkgs.pkgs = pkgs;

                # build nix caches from external
                nix.settings = nixpkgs.lib.mapAttrs (_: nixpkgs.lib.flatten) (
                  nixpkgs.lib.zipAttrs (
                    nixpkgs.lib.attrValues (
                      nixpkgs.lib.mapAttrs (_: v: v.cache) (
                        nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "cache") external
                      )
                    )
                  )
                );

                # import home-manager modules
                home-manager.sharedModules = (
                  nixpkgs.lib.mapAttrsToList (n: v: v.hm-modules."${n}") (
                    nixpkgs.lib.filterAttrs (_: nixpkgs.lib.hasAttr "hm-modules") external
                  )
                );

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
        rec {
          desktops =
            let
              makeModules =
                pkgs: hostFile:
                [
                  home-manager.nixosModules.home-manager
                  inputs.stylix.nixosModules.stylix
                ]
                ++ makeModules' "desktops" pkgs hostFile;
            in
            {
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
                      modules = makeModules pkgs ./planets/desktops/woztop-horizon/host.nix;
                    };
                  };
                weck =
                  let
                    system = "x86_64-linux";
                    pkgs = configNixpkgs' [ inputs.jovian.overlays.default ] system;
                  in
                  {
                    trajectory = "";
                    orbits = [ ];
                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = [
                        inputs.jovian.nixosModules.default
                      ]
                      ++ makeModules pkgs ./planets/desktops/weck/host.nix;
                    };
                  };
                wlab =
                  let
                    system = "x86_64-linux";
                    pkgs = configNixpkgs system;
                  in
                  {
                    trajectory = "";
                    orbits = [ ];

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeModules pkgs ./planets/desktops/wlab/host.nix;
                    };
                  };
              };
            };

          taurus =
            let
              makeModules =
                pkgs: hostFile: [ (_: { solarsys.moons = taurus.moons; }) ] ++ makeModules' "taurus" pkgs hostFile;
            in
            {
              moons = {
                amateru =
                  let
                    system = "aarch64-linux";
                    pkgs = configNixpkgs' [
                      (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
                    ] system;
                  in
                  {
                    trajectory = {
                      host = "10.11.235.1";
                      port = 22;
                    };
                    orbits = [ "nas" ];
                    satellites = {
                      wg_private = {
                        path = "./satellites/taurus/amateru/wg_private";
                        destination = "/keys/wg_private";
                      };
                      ensky_gossip_secret = {
                        path = "./satellites/common/ensky_gossip_secret";
                        destination = "/keys/ensky_gossip_secret";
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
                arion =
                  let
                    system = "aarch64-linux";
                    pkgs = configNixpkgs' [
                      (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
                    ] system;
                  in
                  {
                    trajectory = {
                      host = "10.11.235.21";
                      port = 22;
                    };
                    orbits = [ "runner" ];
                    satellites = {
                      wg_private = {
                        path = "./satellites/taurus/arion/wg_private";
                        destination = "/keys/wg_private";
                      };
                      ensky_gossip_secret = {
                        path = "./satellites/common/ensky_gossip_secret";
                        destination = "/keys/ensky_gossip_secret";
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
                auriga =
                  let
                    system = "aarch64-linux";
                    pkgs = configNixpkgs' [
                      (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
                    ] system;
                  in
                  {
                    trajectory = {
                      host = "10.11.235.22";
                      port = 22;
                    };
                    orbits = [ "runner" ];
                    satellites = {
                      wg_private = {
                        path = "./satellites/taurus/auriga/wg_private";
                        destination = "/keys/wg_private";
                      };
                      ensky_gossip_secret = {
                        path = "./satellites/common/ensky_gossip_secret";
                        destination = "/keys/ensky_gossip_secret";
                      };
                    };

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeModules pkgs ./planets/taurus/auriga/host.nix;
                    };
                  };
                arkas =
                  let
                    system = "aarch64-linux";
                    pkgs = configNixpkgs' [
                      (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
                    ] system;
                  in
                  {
                    trajectory = {
                      host = "10.11.235.31";
                      port = 22;
                    };
                    orbits = [ "runner" ];
                    satellites = {
                      wg_private = {
                        path = "./satellites/taurus/arkas/wg_private";
                        destination = "/keys/wg_private";
                      };
                      ensky_gossip_secret = {
                        path = "./satellites/common/ensky_gossip_secret";
                        destination = "/keys/ensky_gossip_secret";
                      };
                    };

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeModules pkgs ./planets/taurus/arkas/host.nix;
                    };
                  };
                ahra =
                  let
                    system = "aarch64-linux";
                    pkgs = configNixpkgs' [
                      (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
                    ] system;
                  in
                  {
                    trajectory = {
                      host = "10.11.235.31";
                      port = 22;
                    };
                    orbits = [
                      "nas"
                      "runner"
                    ];
                    satellites = {
                      wg_private = {
                        path = "./satellites/taurus/ahra/wg_private";
                        destination = "/keys/wg_private";
                      };
                      ensky_gossip_secret = {
                        path = "./satellites/common/ensky_gossip_secret";
                        destination = "/keys/ensky_gossip_secret";
                      };
                    };

                    core = nixpkgs.lib.nixosSystem {
                      inherit system specialArgs;
                      modules = makeModules pkgs ./planets/taurus/ahra/host.nix;
                    };
                  };
                wangshu =
                  let
                    system = "x86_64-linux";
                    pkgs = configNixpkgs system;
                  in
                  {
                    trajectory = {
                      host = "192.168.0.221";
                      port = 22;
                    };
                    orbits = [ "runner" ];
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
                veles =
                  let
                    system = "x86_64-linux";
                    pkgs = configNixpkgs system;
                  in
                  {
                    trajectory = {
                      host = "192.168.0.243";
                      port = 22;
                    };
                    orbits = [ "runner" ];
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
