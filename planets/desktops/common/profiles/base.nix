{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../../../../common/profiles/base.nix
    ./user.nix
  ];

  nix = {
    registry =
      let
        nixRegistry = builtins.mapAttrs (_: v: { flake = v; }) (
          lib.filterAttrs (_: value: value ? outputs) inputs
        );
      in
      nixRegistry;

    gc.automatic = false;
  };

  boot.initrd.systemd.enable = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  environment.homeBinInPath = true;

  # extra programs
  programs.firejail.enable = true;
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  programs.fish.interactiveShellInit = ''
    function bonk
      nix shell ${builtins.toString ../../../../.}#$argv
    end
  '';

  # services
  ## oom killer
  services.earlyoom = {
    enable = true;
    enableNotifications = false;
  };
  services.udisks2.enable = true;

  # rtkit
  security.rtkit.enable = true;
}
