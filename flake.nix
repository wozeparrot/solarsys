{
  description = "woze's nix system";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "/unstable";
    };

    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    master.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, home-manager, unstable, master }:
    let
      system = "x86_64-linux";

      pkgs = import unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
      mpkgs = import master {
        inherit system;
        config = { allowUnfree = true; };
      };
    in
    {
      nixosConfigurations.nixos =
        let
          specialArgs = { inherit pkgs mpkgs; };

          hm-nixos-as-super = { config, ... }: {
            options.home-manager.user = unstable.lib.mkOption {
              type = unstable.lib.types.attrsOf
                (unstable.lib.types.submoduleWith {
                  modules = [ ];
                  specialArgs = specialArgs // { super = config; };
                });
            };
          };

          modules = [
            home-manager.nixosModules.home-manager
            hm-nixos-as-super
            ./host/configuration.nix
          ];
        in
        unstable.lib.nixosSystem { inherit system modules specialArgs; };
    };
}
