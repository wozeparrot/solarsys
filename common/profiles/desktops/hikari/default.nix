{ config, pkgs, ... }:
{
  imports = [
    ../common/wayland
  ];

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
  };

  # system config
  environment.systemPackages = with pkgs; [
    hikari
  ];

  services.greetd = {
    settings = {
      default_session = {
        command =
          let
            hikari-run = pkgs.writeShellScriptBin "hikari-run" ''
              #!/bin/sh

              export XDG_SESSION_TYPE=wayland
              export XDG_SESSION_DESKTOP=hikari
              export XDG_CURRENT_DESKTOP=hikari

              export MOZ_ENABLE_WAYLAND=1
              export QT_QPA_PLATFORM=wayland-egl
              export SDL_VIDEODRIVER=wayland
              export _JAVA_AWT_WM_NONREPARENTING=1

              systemctl --user import-environment
              systemd-cat --identifier=hikari dbus-run-session hikari
            '';
          in
          "${pkgs.greetd.greetd}/bin/agreety --cmd ${hikari-run}/bin/hikari-run";
      };
    };
  };

  security.pam.services.hikari-unlocker = { };
}
