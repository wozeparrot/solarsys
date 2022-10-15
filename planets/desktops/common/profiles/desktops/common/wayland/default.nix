{
  config,
  pkgs,
  ...
}: {
  # home-manager config
  home-manager.users.woze = {
    home.packages = with pkgs; [
      fnott
      fuzzel
      grim
      hyprpicker.hyprpicker
      oguri
      pngquant
      slurp
      ss.zscroll
      swappy
      swaylock-effects
      wob
      wofi
      wtype

      wdisplays
      wlr-randr

      (pkgs.writeShellScriptBin "wl-screenshot" ''
        grim -g "$(slurp)" - | swappy -f - -o - | pngquant -o - - | wl-copy -t 'image/png'
      '')

      (pkgs.writeShellScriptBin "wl-launcher" ''
        # fuzzel -r 0 -b 151510ff -t d2cad3ff -s 6691d2ff -C aa3c9fff -m a52e4dff -w 40 -l 12 -B 2
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

      (pkgs.writeShellScriptBin "wl-lockscreen" ''
        swaylock -i ${../../../../misc/lockscreen.jpg} -F --effect-pixelate 128 --effect-vignette 0.2:0.2
      '')

      (pkgs.writeShellScriptBin "wl-colorpicker" ''
        pkill -9 hyprpicker
        hyprpicker --no-fancy | wl-copy -n
      '')
    ];

    xdg.configFile."oguri/config".text = ''
      [output *]
      image=${../../../../misc/wallpaper.png}
      filter=best
      scaling-mode=fill
      anchor=center
    '';

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
      theme = ./rofi-theme.rasi;
    };

    programs.waybar = {
      enable = true;
      package = pkgs.nixpkgs-wayland.waybar.override {
        swaySupport = false;
        withMediaPlayer = true;
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

          modules-left = ["custom/launcher" "hyprland/window" "tray"];
          modules-center = ["battery" "custom/powerdraw" "pulseaudio" "backlight" "cpu" "memory" "temperature" "custom/gpu-usage" "custom/gpu-usage-2" "clock"];
          modules-right = ["custom/media" "custom/lock"];

          # modules
          "custom/launcher" = {
            format = "";
            on-click = "wl-launcher";
            on-click-right = "pkill -9 rofi";
            tooltip = false;
          };

          "hyprland/window" = {
            format = "  {}";
            max-length = 40;
          };

          "tray" = {
            icon-size = 15;
            spacing = 7;
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
            exec = "cat /sys/class/power_supply/BAT0/power_now | awk '{ printf \"%.1f\", ($1/1000000) }'";
            format = "{}W ";
            on-click = "kitty btm";
            tooltip = false;
          };

          "pulseaudio" = {
            format = "{volume}% ";
            format-muted = "";
            on-click = "pavucontrol";
            on-click-right = "pamixer -t";
            tooltip = false;
          };

          "backlight" = {
            format = "{percent}% ";
            on-scroll-up = "light -A 1";
            on-scroll-down = "light -U 1";
          };

          "cpu" = {
            interval = 2;
            format = "{usage}% ";
            on-click = "kitty btm";
            tooltip = false;
          };

          "memory" = {
            interval = 2;
            format = "{}% ";
            on-click = "kitty btm";
            tooltip = false;
          };

          "temperature" = {
            interval = 2;
            hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
            input-filename = "temp1_input";
            format = "{temperatureC}°C ";
            on-click = "kitty btm";
            tooltip = false;
          };

          "custom/gpu-usage" = {
            interval = 2;
            format = "{}% ";
            on-click = "kitty btm";
            exec = "cat /sys/class/drm/card0/device/gpu_busy_percent";
            tooltip = false;
          };

          "custom/gpu-usage-2" = {
            interval = 2;
            format = "{}% ";
            on-click = "kitty btm";
            exec = "cat /sys/class/drm/card1/device/gpu_busy_percent";
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
            on-click = "mpc toggle";
            on-click-right = "kitty ncmpcpp";
            smooth-scroll-threshold = 10;
            on-scroll-up = "mpc next";
            on-scroll-down = "mpc prev";
            tooltip = false;
          };

          "custom/lock" = {
            format = "";
            on-click = "wl-lockscreen";
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
  };

  programs.xwayland.enable = true;
  services.greetd.enable = true;

  security.pam.services.swaylock = {};
}
