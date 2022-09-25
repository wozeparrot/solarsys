{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    home.packages = with pkgs; [
      wofi
      oguri
      fuzzel
      fnott
      grim
      slurp
      swappy
      pngquant
      swaylock-effects

      wlr-randr
      wdisplays

      (pkgs.writeShellScriptBin "wl-screenshot" ''
        grim -g "$(slurp)" - | swappy -f - -o - | pngquant -o - - | wl-copy -t 'image/png'
      '')
    ];

    xdg.configFile."oguri/config".text = ''
      [output *]
      image=~/pictures/wallpapers/starrysky.png
      filter=best
      scaling-mode=fill
      anchor=center
    '';

    xdg.configFile."fnott/fnott.ini".source = ./fnott.ini;

    programs.waybar = {
      enable = true;
      package = pkgs.hyprland.waybar-hyprland;
      settings = [
        {
          layer = "top";
          position = "top";
          output = [
            "eDP-1"
            "eDP-2"
          ];

          modules-left = [ "cpu" "memory" "mpd" "tray" ];
          modules-center = [ ];
          modules-right = [ "backlight" "pulseaudio" "clock" "battery" ];

          modules = {
            "mpd" = {
              format = "{stateIcon}";
              format-disconnected = "";
              format-stopped = "";
              state-icons = {
                paused = "";
                playing = "";
              };
              tooltip = false;
            };
            "tray" = {
              icon-size = 12;
              spacing = 10;
            };
            "network" = {
              format-wifi = "W {signalStrength}%";
              format-ethernet = "E";
              format-disconnected = "";
              tooltip = false;
              interval = 10;
            };
            "backlight" = {
              on-scroll-up = "light -A 1";
              on-scroll-down = "light -U 1";
              format = " {percent}%";
              tooltip = false;
            };
            "clock" = {
              interval = 1;
              format = "{:%H:%M:%S}";
              today-format = "<b><big><u>{}</u></big></b>";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };
            "pulseaudio" = {
              format = "{icon} {volume}%";
              format-muted = "";
              format-icons = {
                default = [ "" "" "" ];
              };
              on-click = "pavucontrol";
              tooltip = false;
            };
            "battery" = {
              format-icons = [ "" "" "" "" "" ];
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              interval = 30;
              states = {
                good = 95;
                warning = 30;
                critical = 15;
              };
            };
            "memory" = {
              format = " {}%";
              interval = 2;
            };
            "cpu" = {
              format = " {usage}%";
              interval = 2;
            };
          };
        }
      ];
      style = builtins.readFile ./waybar.css;
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };

  programs.xwayland.enable = true;
  services.greetd.enable = true;

  security.pam.services.swaylock = { };
}
