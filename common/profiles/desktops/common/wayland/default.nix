{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    home.packages = with pkgs; [
      wofi
      oguri
      fuzzel
      fnott
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
      settings = [
        {
          layer = "top";
          position = "top";
          height = 20;
          output = [
            "eDP-1"
          ];
          modules-left = [ "battery" "network" "cpu" "memory" ];
          modules-center = [ "mpd" ];
          modules-right = [ "backlight" "pulseaudio" "clock" "tray" ];
          modules = {
            "mpd" = {
              format = "{stateIcon} - {title} - ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
              format-disconnected = "disconnected";
              format-stopped = "stopped";
              state-icons = {
                paused = "#";
                playing = "^";
              };
              tooltip = false;
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
              format = "{icon} {percent}%";
              format-icons = [ "B" ];
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
              format-muted = "M";
              format-icons = {
                default = [ "S" ];
              };
              on-click = "pavucontrol";
              tooltip = false;
            };
            "battery" = {
              format-icons = [ "." "," "-" "'" "*" ];
              format = "{icon} {capacity}%";
              format-charging = "{icon} {capacity}%";
              format-discharging = "{icon} {capacity}";
              format-full = "{icon} {capacity}%";
              interval = 30;
              states = {
                warning = 30;
                critical = 15;
              };
              tooltip = false;
            };
            "memory" = {
              format = "R {}%";
              states = {
                warning = 70;
                critical = 90;
              };
              interval = 2;
            };
            "cpu" = {
              format = "C {usage}%";
              states = {
                warning = 70;
                critical = 90;
              };
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
  programs.qt5ct.enable = true;
  services.greetd.enable = true;
}
