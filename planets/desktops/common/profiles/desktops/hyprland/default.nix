{ config, pkgs, ... }:
{
  imports = [ ../common/wayland ];

  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hypr/hyprland.conf" = {
      text =
        (builtins.readFile ./hyprland.conf)
        + ''
          plugin = ${pkgs.hyprland-split-monitor-workspaces.split-monitor-workspaces}/lib/libsplit-monitor-workspaces.so
        ''
        + (
          let
            rgb = color: "rgb(${color})";
            rgba = color: alpha: "rgba(${color}${alpha})";
          in
          with config.lib.stylix.colors;
          ''
            decoration {
              col.shadow=${rgba base00 "99"}
            }

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
              ${pkgs.nixpkgs-wayland.kanshi}/bin/kanshictl reload || true
              ${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" hyprpaper wallpaper ,$(${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" hyprpaper listactive | head -n1 | grep -oP '/.*')
            done
          fi
        )
      '';
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

      exec dbus-run-session -- Hyprland
    '')
    (pkgs.writeShellScriptBin "hyprland-gamemode" ''
      #!/usr/bin/env sh
      HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
      if [ "$HYPRGAMEMODE" == 1 ] ; then
          hyprctl --batch "\
              keyword animations:enabled 0;\
              keyword decoration:drop_shadow 0;\
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
      (pkgs.xdph.xdg-desktop-portal-hyprland.override { inherit (pkgs.hyprland) hyprland; })
    ];
  };
}
