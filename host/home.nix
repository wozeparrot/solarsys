{ config, pkgs, mpkgs, ... }:

{
  imports = [
    ../common/home.nix
  ];

  # Packages
  home.packages = with pkgs; [
    ss.rofi
    herbstluftwm
    i3lock-color
    polybarFull
    dunst
    sxhkd

    pypy3
    python3
    python3Packages.python-language-server

    docker-compose

    ghidra-bin
    krita
    vlc
    zathura
    antimicroX
    torrential
    audacity
    lmms
    mpkgs.freecad
    gnome3.file-roller
    kicad

    radeontop
    simplescreenrecorder

    the-powder-toy

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
    blurExclude = [ "class_g = 'slop'" "class_g = 'discord_overlay.py'" ];
    package = pkgs.ss.picom;

    extraOptions = ''
      blur: {
        method = "dual_kawase";
        strength = 10;
        background = false;
        background-frame = false;
        background-fixed = false;
      }
    '';
  };

  services.kdeconnect.indicator = true;
  services.pulseeffects.enable = true;
  services.nextcloud-client.enable = true;

  xsession.enable = true;
  xsession.windowManager.command = "${pkgs.herbstluftwm}/bin/herbstluftwm";
  xsession.initExtra = ''
    sxhkd &
    dunst &
    $HOME/.config/polybar/launch.sh
    feh --bg-fill $HOME/pictures/wallpapers/984194.jpg
  '';
  xsession.scriptPath = ".hm-xsession";
}
