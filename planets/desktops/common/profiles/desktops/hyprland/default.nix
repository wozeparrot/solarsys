{ config, pkgs, ... }:
{
  imports = [ ../common/wayland ];

  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hypr/hyprland.conf" = {
      text =
        (builtins.readFile ./hyprland.conf)
        + ''''
        + (
          let
            rgb = color: "rgb(${color})";
            rgba = color: alpha: "rgba(${color}${alpha})";
          in
          with config.lib.stylix.colors;
          ''
            general {
              col.active_border=${rgb base0D}
              col.inactive_border=${rgb base03}
            }
          ''
        );
      onChange = ''
        (
          XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          if [[ -d "/tmp/hypr" || -d "$XDG_RUNTIME_DIR/hypr" ]]; then
            for i in $(${pkgs.hyprland.hyprland}/bin/hyprctl instances -j | jq ".[].instance" -r); do
              ${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" reload config-only
              # ${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" hyprpaper wallpaper ,$(${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" hyprpaper listactive | head -n1 | grep -oP '/.*')
            done
          fi
        )
      '';
    };

    services.hyprpolkitagent.enable = false;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = [
          {
            timeout = 180;
            on-timeout = "hyprlock";
          }
        ];
      };
    };
  };

  # system config
  environment.systemPackages = with pkgs; [
    hyprland.hyprland
    (pkgs.writeShellScriptBin "hyprland-run" ''
      #!/bin/sh

      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=Hyprland
      export XDG_CURRENT_DESKTOP=Hyprland

      export GDK_BACKEND="wayland,x11"
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM="wayland;wayland-egl;xcb"
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QT_AUTO_SCREEN_SCALE_FACTOR=1
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export XCURSOR_SIZE=24
      export NIXOS_OZONE_WL=1
      export AQ_DRM_DEVICES="/dev/dri/card2:/dev/dri/card1:/dev/dri/card0"

      systemctl --user stop graphical-session.target
      systemctl --user stop graphical-session-pre.target
      systemctl --user stop wayland-desktop-session.target

      exec dbus-run-session -- start-hyprland
    '')
    (pkgs.writeShellScriptBin "hyprland-gamemode" ''
      #!/usr/bin/env sh
      HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
      if [ "$HYPRGAMEMODE" == 1 ] ; then
          hyprctl --batch "\
              keyword animations:enabled 0;\
              keyword decoration:shadow:enabled 0;\
              keyword decoration:blur:enabled 0;\
              keyword general:gaps_in 0;\
              keyword general:gaps_out 0;\
              keyword general:border_size 1;\
              keyword decoration:rounding 0"
          exit
      fi
      hyprctl reload
    '')
  ];

  xdg.portal = {
    extraPortals = [
      (pkgs.hyprland.xdg-desktop-portal-hyprland.override { inherit (pkgs.hyprland) hyprland; })
    ];
  };
}
