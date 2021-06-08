{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    home.packages = with pkgs; [
      wofi
    ];

    programs.mako = {
      enable = true;
      defaultTimeout = 5000;
      maxVisible = 7;
    };

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
              format = "{stateIcon} {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
              format-disconnected = "disconnected";
              format-stopped = "stopped";
              state-icons = {
                paused = "";
                playing = "";
              };
              tooltip = false;
            };
            "network" = {
              format-wifi = " {signalStrength}%";
              format-ethernet = "";
              format-disconnected = "";
              tooltip = false;
            };
            "backlight" = {
              on-scroll-up = "light -A 1";
              on-scroll-down = "light -U 1";
              format = "{icon} {percent}%";
              format-icons = [ "" ];
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
              format-muted = "";
              format-icons = {
                default = [ "" ];
                headphones = [ "" ];
              };
              on-click = "pavucontrol";
              tooltip = false;
            };
            "battery" = {
              format-icons = [ "" "" "" "" "" ];
              format = "{icon} {capacity}%";
              format-charging = "{icon} {capacity}%";
              format-discharging = "{icon} {time}";
              format-full = "{icon} {capacity}%";
              interval = 30;
              states = {
                warning = 30;
                critical = 15;
              };
              tooltip = false;
            };
            "memory" = {
              format = " {}%";
              states = {
                warning = 70;
                critical = 90;
              };
            };
            "cpu" = {
              format = " {usage}%";
              states = {
                warning = 70;
                critical = 90;
              };
            };
          };
        }
      ];
      style = builtins.readFile ./waybar.css;
    };
  };

  programs.xwayland.enable = true;
  services.greetd.enable = true;
}
