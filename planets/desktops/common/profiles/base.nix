{ config, pkgs, inputs, lib, ... }:
{
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

  # services
  ## oom killer
  services.earlyoom.enable = true;

  # rtkit
  security.rtkit.enable = true;
}
