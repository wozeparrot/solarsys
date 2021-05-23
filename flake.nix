{
  description = "woze's nix system (branched)";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";
    master.url = "github:NixOS/nixpkgs/master";

    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, unstable, master, utils, home-manager, ... }:
    utils.lib.systemFlake {
      inherit self inputs;

      devShellBuilder = channels: (import ./shell.nix { pkgs = channels.nixpkgs; });

      overlaysDir =
        let
          overlayDir = ./common/overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (builtins.attrNames (builtins.readDir overlayDir));
          pathsToImportedAttrs = paths:
            (values: f: builtins.listToAttrs (map f values)) paths (path: {
              name = unstable.lib.removeSuffix ".nix" (baseNameOf path);
              value = import path;
            });
        in
        (builtins.attrValues (pathsToImportedAttrs overlayPaths)) ++ [
          inputs.neovim-nightly-overlay.overlay
        ];

      sharedOverlays = self.overlaysDir;

      channels = {
        nixpkgs.input = unstable;
        master.input = master;
      };
      channelsConfig.allowUnfree = true;

      hostDefaults = {
        modules = [
          home-manager.nixosModules.home-manager
          ({ ... }: {
            system.configurationRevision = unstable.lib.mkIf (self ? rev) self.rev;
          })
        ];
        extraArgs = { inherit inputs utils; };
      };

      hosts = {
        woztop = {
          modules = [ ./hosts/woztop/host.nix ];
        };
      };
    };
}
