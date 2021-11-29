{ config, pkgs, ... }:

{
  imports = [
    ../common/home.nix
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

    (
      pkgs.writeShellScriptBin "run_gpu" ''
        #!/usr/bin/env bash

        DRI_PRIME=1 exec -a "$0" "$@"
      ''
    )
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ wlrobs ];
  };

  # Services
  services.kdeconnect.indicator = true;
  services.syncthing.enable = true;

  home.stateVersion = "20.09";
}
