{ config, pkgs, ... }:
{
  imports = [ ../common/wayland ];

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

    home.packages =
      let
        hikari-run = pkgs.writeShellScriptBin "hikari-run" ''
          #!/bin/sh

          export XDG_SESSION_TYPE=wayland
          export XDG_SESSION_DESKTOP=hikari
          export XDG_CURRENT_DESKTOP=hikari

          export GDK_BACKEND=wayland
          export MOZ_ENABLE_WAYLAND=1
          export QT_QPA_PLATFORM=wayland-egl
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
          export XCURSOR_SIZE=24
          export NIXOS_OZONE_WL=1

          systemd-cat --identifier=hikari dbus-run-session hikari
        '';
      in
      [ hikari-run ];
  };

  # system config
  environment.systemPackages = with pkgs; [ hikari ];

  security.pam.services.hikari-unlocker = { };
}
