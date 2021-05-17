{
  description = "woze's nix system (branched)";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = inputs@{ self, unstable, master, home-manager }:
    let
      inherit (builtins) attrNames attrValues readDir listToAttrs;
      inherit (unstable) lib;
      inherit (lib) removeSuffix;

      pathsToImportedAttrs = paths:
        (values: f: listToAttrs (map f values)) paths (path: {
          name = removeSuffix ".nix" (baseNameOf path);
          value = import path;
        });

      system = builtins.readFile ./host/system.system;

      overlays =
        let
          overlayDir = ./common/overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (attrNames (readDir overlayDir));
        in
        pathsToImportedAttrs overlayPaths;

      pkgsImport = pkgs:
        import pkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = attrValues overlays;
        };

      pkgs = pkgsImport unstable;
      mpkgs = pkgsImport master;
    in
    {
      nixosConfigurations = {
        "${builtins.readFile ./host/hostname.system}" =
        let
          specialArgs = { inherit pkgs mpkgs inputs overlays; };

          hm-nixos-as-super = { config, ... }: {
            options.home-manager.users = unstable.lib.mkOption {
              type = unstable.lib.types.attrsOf (unstable.lib.types.submoduleWith {
                modules = [ ];
                specialArgs = specialArgs // {
                  super = config;
                };
              });
            };
          };

          modules = [
            home-manager.nixosModules.home-manager
            hm-nixos-as-super
            ({ ... }: {
              system.configurationRevision = unstable.lib.mkIf (self ? rev) self.rev;
            })
            ./host/configuration.nix
          ];
        in
        unstable.lib.nixosSystem { inherit system modules specialArgs; };
      };

      legacyPackages."${system}" = pkgs;

      devShell.${system} = import ./shell.nix { inherit pkgs; };
    };
}
