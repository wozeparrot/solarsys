{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."river/init" = {
      source = ./init;
      executable = true;
    };

  # system config
  environment.systemPackages = with pkgs; [
    river
  ];

  # services.greetd = {
  #   settings = {
  #     default_session = {
  #       command =
  #         let
  #           hikari-run = pkgs.writeShellScriptBin "river-run" ''
  #             #!/bin/sh

  #             export XDG_SESSION_TYPE=wayland
  #             export XDG_SESSION_DESKTOP=river
  #             export XDG_CURRENT_DESKTOP=river

  #             export MOZ_ENABLE_WAYLAND=1
  #             export QT_QPA_PLATFORM=wayland-egl
  #             export SDL_VIDEODRIVER=wayland
  #             export _JAVA_AWT_WM_NONREPARENTING=1

  #             systemctl --user import-environment
  #             systemd-cat --identifier=river dbus-run-session river
  #           '';
  #         in
  #         "${pkgs.greetd.greetd}/bin/agreety --cmd ${river-run}/bin/river-run";
  #     };
  #   };
  # };
}