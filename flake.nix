{
  description = "woze's nix system (branched)";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, home-manager, unstable, master }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import unstable {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          ./common/overlays/pkgs.nix
        ];
      };
      mpkgs = import master {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          ./common/overlays/pkgs.nix
        ];
      };
    in
    {
      nixosConfigurations.woztop =
        let
          specialArgs = { inherit pkgs mpkgs; };

          modules = [
            home-manager.nixosModules.home-manager
            ./host/configuration.nix
          ];
        in
        unstable.lib.nixosSystem { inherit system modules specialArgs; };
    };
}
