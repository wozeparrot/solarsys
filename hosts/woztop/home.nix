{ config, pkgs, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  # Packages
  home.packages = with pkgs; [
    pkgs.mpkgs.rofi
    herbstluftwm
    i3lock-color
    polybarFull
    dunst
    sxhkd

    python3
    python3Packages.python-language-server

    docker-compose

    zathura
    gnome3.file-roller

    radeontop
    simplescreenrecorder

    teams

    wineWowPackages.staging
    appimage-run
    scrcpy
    flameshot
  ];

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-v4l2sink ];
  };

  # Services
  services.picom = {
    enable = true;
    blur = true;
    blurExclude = [
      "class_g = 'slop'"
      "class_g = 'discord_overlay.py'"
      "window_type = 'dock'"
      "window_type = 'desktop'"
    ];
    experimentalBackends = true;
    vSync = true;
    package = pkgs.ss.picom;

    extraOptions = ''
      blur: {
        method = "dual_kawase";
        strength = 12;
        background = false;
        background-frame = false;
        background-fixed = false;
      }
    '';
  };

  services.kdeconnect.indicator = true;
  services.nextcloud-client.enable = true;

  xsession.enable = true;
  xsession.windowManager.command = "${pkgs.herbstluftwm}/bin/herbstluftwm";
  xsession.initExtra = ''
    sxhkd &
    dunst &
    $HOME/scripts/monitor.sh &
    feh --bg-fill $HOME/pictures/wallpapers/starrysky.jpg &
  '';
  xsession.scriptPath = ".hm-xsession";
}
