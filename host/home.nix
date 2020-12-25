{ config, pkgs, mpkgs, ... }:

{
  imports = [
    ../common/home.nix
  ];

  # Packages
  home.packages = with pkgs; [
    lxappearance
    ss.rofi
    herbstluftwm
    i3lock-color
    pcmanfm
    polybarFull
    sxhkd
    dunst
    xfce.exo

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

  programs.autorandr = {
    enable = true;
    hooks.postswitch = { "update" = "$HOME/scripts/monitor.sh"; };
    profiles = {
      "undocked" = {
        fingerprint = {
          eDP-1 =
            "00ffffffffffff0006afed380000000000190104952213780251259358578f281f505400000001010101010101010101010101010101783780b470382e406c30aa0058c11000001a602c80b470382e406c30aa0058c11000001a000000fe003238483830804231353648544e000000000000410296001000000a010a20200009";
        };
        config = {
          eDP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.05";
          };
        };
      };
      "docked" = {
        fingerprint = {
          eDP-1 =
            "00ffffffffffff0006afed380000000000190104952213780251259358578f281f505400000001010101010101010101010101010101783780b470382e406c30aa0058c11000001a602c80b470382e406c30aa0058c11000001a000000fe003238483830804231353648544e000000000000410296001000000a010a20200009";
          DP-1 =
            "00ffffffffffff004c2de8083242565a2d160104a5341d78222cc1a45650a1280f5054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c450009252100001e000000fd00384b1e5111000a202020202020000000fc00533234423234300a2020202020000000ff0048544e434230303938340a202000ac";
        };
        config = {
          eDP-1 = {
            enable = true;
            crtc = 1;
            primary = false;
            mode = "1920x1080";
            position = "1920x0";
            rate = "60.05";
          };
          DP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.00";
          };
        };
      };
    };
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
    dunst &
    $HOME/.config/polybar/launch.sh
    feh --bg-fill $HOME/pictures/wallpapers/984194.jpg
  '';
  xsession.scriptPath = ".hm-xsession";
}
