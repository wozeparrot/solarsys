{ config, pkgs, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  # Packages
  home.packages = with pkgs; [
    python3

    docker-compose

    zathura
    gnome3.file-roller

    radeontop
    simplescreenrecorder

    teams

    wineWowPackages.staging
    appimage-run
  ];

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-v4l2sink ];
  };

  # Services
  services.kdeconnect.indicator = true;
  services.nextcloud-client.enable = true;
}
