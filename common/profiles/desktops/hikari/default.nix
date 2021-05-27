{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    home.packages = with pkgs; [];
  };

  # system config
  environment.systemPackages = [
    hikari
  ];

  programs.xwayland.enable = true;

  security.pam.services.hikari-unlocker = {};
}
