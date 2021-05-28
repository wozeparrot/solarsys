{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hikari/hikari.conf".source = ./hikari.conf;
    xdg.configFile."hikari/autostart" = {
      executable = true;
      text = ''
        exec waybar
      '';
    };

    home.packages = with pkgs; [
      wofi
    ];

    programs.mako = {
      enable = true;
      defaultTimeout = 2000;
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
            };
            "network" = {
              format-wifi = "{signalStrength}%";
              format-disconnected = "";
            };
            "backlight" = {
              on-scroll-up = "light -A 1";
              on-scroll-down = "light -U 1";
            };
            "clock" = {
              interval = 1;
              format = "{:%H:%M:%S}";
              today-format = "<big><u>{}</u></big>";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };
          };
        }
      ];
    };
  };

  # system config
  environment.systemPackages = with pkgs; [
    hikari
  ];

  programs.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd hikari";
      };
    };
  };

  security.pam.services.hikari-unlocker = {};
}
