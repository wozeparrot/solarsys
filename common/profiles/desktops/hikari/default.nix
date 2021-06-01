{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hikari/hikari.conf".source = ./hikari.conf;
    xdg.configFile."hikari/autostart" = {
      executable = true;
      text = ''
        systemctl --user import-environment

        systemctl --user start kdeconnect.service
        systemctl --user start kdeconnect-indicator.service
        systemctl --user start nextcloud-client.service

        exec waybar  
      '';
    };

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

  # system config
  environment.systemPackages = with pkgs; [
    hikari
  ];

  programs.xwayland.enable = true;
  programs.qt5ct.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {

        command = let
          hikari-run = pkgs.writeShellScriptBin "hikari-run" ''
            #!/bin/sh

            export XDG_SESSION_TYPE=wayland
            export XDG_SESSION_DESKTOP=hikari
            export XDG_CURRENT_DESKTOP=hikari

            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM=wayland-egl
            export QT_QPA_PLATFORMTHEME=qt5ct
            export SDL_VIDEODRIVER=wayland
            export _JAVA_AWT_WM_NONREPARENTING=1

            systemd-cat --identifier=hikari dbus-run-session hikari
          '';
        in
          "${pkgs.greetd.greetd}/bin/agreety --cmd ${hikari-run}/bin/hikari-run";
      };
    };
  };

  security.pam.services.hikari-unlocker = {};
}
