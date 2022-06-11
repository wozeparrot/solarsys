{ config, pkgs, ... }:
{
  imports = [
    ../common/wayland
  ];

  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hypr/hyprland.conf" = {
      source = ./hyprland.conf;
    };
  };

  # system config
  environment.systemPackages = with pkgs; [
    wozepkgs.hyprland
    swaylock-effects
  ];

  services.greetd = {
    settings = {
      default_session = {
        command =
          let
            hyprland-run = pkgs.writeShellScriptBin "hyprland-run" ''
              #!/bin/sh

              export XDG_SESSION_TYPE=wayland
              export XDG_SESSION_DESKTOP=hyprland
              export XDG_CURRENT_DESKTOP=hyprland

              export MOZ_ENABLE_WAYLAND=1
              export QT_QPA_PLATFORM=wayland-egl
              export QT_QPA_PLATFORMTHEME=qt5ct
              export SDL_VIDEODRIVER=wayland
              export _JAVA_AWT_WM_NONREPARENTING=1

              systemd-cat --identifier=hyprland dbus-run-session hyprland
            '';
          in
          "${pkgs.greetd.greetd}/bin/agreety --cmd ${hyprland-run}/bin/hyprland-run";
      };
    };
  };

  security.pam.services.swaylock = { };
}
