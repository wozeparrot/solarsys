{
  config,
  pkgs,
  ...
}: {
  # home-manager config
  home-manager.users.woze = {
    home.packages = with pkgs; [
      cliphist
      fnott
      fuzzel
      grim
      hyprpicker.hyprpicker
      pngquant
      slurp
      ss.zscroll
      swappy
      swww
      wayvnc
      wob
      wofi
      wtype
      xorg.xrdb

      wdisplays
      wlr-randr

      (pkgs.writeShellScriptBin "wl-screenshot" ''
        grim -g "$(slurp)" - | swappy -f - -o - | pngquant -o - - | wl-copy -t 'image/png'
      '')

      (pkgs.writeShellScriptBin "wl-launcher" ''
        pkill -9 rofi
        rofi -show drun
      '')

      (pkgs.writeShellScriptBin "wl-calc" ''
        pkill -9 rofi
        rofi -show calc
      '')

      (pkgs.writeShellScriptBin "wl-emoji" ''
        pkill -9 rofi
        rofi -show emoji
      '')

      (pkgs.writeShellScriptBin "wl-colorpicker" ''
        pkill -9 hyprpicker
        hyprpicker --no-fancy | wl-copy -n
      '')

      (pkgs.writeShellScriptBin "wl-clipmanager" ''
        pkill -9 rofi
        cliphist list | rofi -dmenu | cliphist decode | wl-copy
      '')
    ];

    xdg.configFile."fnott/fnott.ini".source = ./fnott.ini;

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
      ];
      cycle = true;
      extraConfig = {
        # general settings
        modi = "drun,calc,emoji";
        case-sensitive = false;
        filter = "";
        scroll-method = 0;
        normalize-match = true;
        show-icons = true;
        icon-theme = "Papirus";
        window-format = "{w} · {c} · {t}";

        # matching settings
        matching = "normal";
        tokenize = true;

        # history settings
        disable-history = false;
        sorting-method = "normal";
        max-history-size = 50;

        # misc settings
        sort = false;
        threads = 0;
        click-to-exit = true;

        # display settings
        display-drun = "Apps";
        display-calc = "Calc";
        display-emoji = "Emoji";

        # drun settings
        drun-categories = "";
        drun-match-fields = "name,generic,exec,categories,keywords";
        drun-display-format = "{name}";
        drun-show-actions = false;
        drun-url-launcher = "xdg-open";
        drun-use-desktop-cache = false;
        drun-reload-desktop-cache = false;
      };
      # theme = ./rofi-theme.rasi;
    };

    programs.waybar = {
      enable = true;
      package = pkgs.nixpkgs-wayland.waybar;
      systemd = {
        enable = true;
        target = "wayland-desktop-session.target";
      };
      settings = [
        {
          layer = "top";
          position = "top";
          output = [
            "eDP-1"
            "eDP-2"
          ];

          height = 30;
          spacing = 0;
          margin-top = 0;
          margin-bottom = 0;

          modules-left = ["hyprland/window" "tray"];
          modules-center = ["battery" "custom/powerdraw" "pulseaudio" "backlight" "cpu" "memory" "temperature" "custom/gpu-usage" "custom/gpu-usage-2" "clock"];
          modules-right = ["custom/media"];

          "hyprland/window" = {
            format = "  {}";
            max-length = 40;
          };

          "tray" = {
            icon-size = 15;
            spacing = 7;
            show-passive-items = true;
          };

          "battery" = {
            interval = 4;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [" " " " " " " " " "];
            tooltip = false;
          };

          "custom/powerdraw" = {
            interval = 2;
            exec = "${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/power_now | ${pkgs.gawk}/bin/awk '{ printf \"%.1f\", ($1/1000000) }'";
            format = "{}W ";
            tooltip = false;
          };

          "pulseaudio" = {
            format = "{volume}% ";
            format-muted = "";
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right = "${pkgs.pamixer}/bin/pamixer -t";
            tooltip = false;
          };

          "backlight" = {
            format = "{percent}% ";
            on-scroll-up = "${pkgs.light}/bin/light -A 1";
            on-scroll-down = "${pkgs.light}/bin/light -U 1";
          };

          "cpu" = {
            interval = 2;
            format = "{usage}% ";
            tooltip = false;
          };

          "memory" = {
            interval = 2;
            format = "{}% ";
            tooltip = false;
          };

          "temperature" = {
            interval = 2;
            hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
            input-filename = "temp1_input";
            format = "{temperatureC}°C ";
            tooltip = false;
          };

          "custom/gpu-usage" = {
            interval = 2;
            format = "{}% ";
            exec = "${pkgs.coreutils}/bin/cat /sys/class/drm/card0/device/gpu_busy_percent";
            tooltip = false;
          };

          "custom/gpu-usage-2" = {
            interval = 2;
            format = "{}% ";
            exec = "${pkgs.coreutils}/bin/cat /sys/class/drm/card1/device/gpu_busy_percent";
            tooltip = false;
          };

          "clock" = {
            interval = 1;
            format = "{:%H:%M:%S}";
            today-format = "<b><big><u>{}</u></big></b>";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          "custom/media" = {
            format = "{}";
            exec = "${./bar-mpd-zscroll.sh}";
            escape = true;
            on-click = "${pkgs.mpc-cli}/bin/mpc toggle";
            smooth-scroll-threshold = 10;
            on-scroll-up = "${pkgs.mpc-cli}/bin/mpc next";
            on-scroll-down = "${pkgs.mpc-cli}/bin/mpc prev";
            tooltip = false;
          };
        }
      ];
      style = builtins.readFile ./waybar.css;
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    systemd.user.targets.wayland-desktop-session = {
      Unit = {
        Description = "wayland desktop session";
        Documentation = ["man:systemd.special(7)"];
        BindsTo = ["graphical-session.target"];
        Wants = ["graphical-session-pre.target"];
        After = ["graphical-session-pre.target"];
      };
    };
  };

  programs.xwayland.enable = true;
}
