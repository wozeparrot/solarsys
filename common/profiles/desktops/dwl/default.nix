{ config, pkgs, ... }:
{
  imports = [
    ../common/wayland
  ];

  # system config
  environment.systemPackages = with pkgs; [
    (dwl.override {
      src = pkgs.fetchFromGitHub {
        owner = "djpohly";
        repo = "dwl";
        rev = "1183a319a02cf89aa7311124fca7f15332c80547";
        sha256 = "sha256-lfUAymLA4+E9kULZIueA+9gyVZYgaVS0oTX0LJjsSEs=";
      };

      patches = [
        ./patches/monitor_config.patch
        ./patches/pointer_contraints.patch
      ];

      conf = ./config.def.h;
    })
  ];

  # services.greetd = {
  #   settings = {
  #     default_session = {
  #       command =
  #         let
  #           river-run = pkgs.writeShellScriptBin "dwl-run" ''
  #             #!/bin/sh

  #             export XDG_SESSION_TYPE=wayland
  #             export XDG_SESSION_DESKTOP=dwl
  #             export XDG_CURRENT_DESKTOP=dwl

  #             export MOZ_ENABLE_WAYLAND=1
  #             export QT_QPA_PLATFORM=wayland-egl
  #             export QT_QPA_PLATFORMTHEME=qt5ct
  #             export SDL_VIDEODRIVER=wayland
  #             export _JAVA_AWT_WM_NONREPARENTING=1

  #             systemctl --user import-environment
  #             systemd-cat --identifier=river dbus-run-session dwl
  #           '';
  #         in
  #         "${pkgs.greetd.greetd}/bin/agreety --cmd ${dwl-run}/bin/dwl-run";
  #     };
  #   };
  # };
}
