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
      system = "x86_64-linux";

      pkgs = import unstable {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (import ./common/overlays/pkgs.nix)
        ];
      };
      mpkgs = import master {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (import ./common/overlays/pkgs.nix)
        ];
      };
    in
    {
      nixosConfigurations.woztop =
        let
          specialArgs = { inherit pkgs mpkgs inputs; };

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
            ({...}: {
              system.configurationRevision = unstable.lib.mkIf (self ? rev) self.rev;
            })
            ./host/configuration.nix
          ];
        in
        unstable.lib.nixosSystem { inherit system modules specialArgs; };

      devShell.${system} = import ./shell.nix { inherit pkgs; };
    };
}
