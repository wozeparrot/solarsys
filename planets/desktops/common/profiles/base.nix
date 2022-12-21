{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../../../common/profiles/base.nix
    ./user.nix
  ];

  nix.gc.automatic = false;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  environment.homeBinInPath = true;

  # extra programs
  programs.firejail.enable = true;
  programs.nix-ld.enable = true;

  # services
  ## oom killer
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };
  services.udisks2.enable = true;

  # rtkit
  security.rtkit.enable = true;
}
