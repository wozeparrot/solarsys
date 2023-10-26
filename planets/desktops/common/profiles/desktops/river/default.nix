{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/wayland
  ];

  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."river/init" = {
      source = ./init;
      executable = true;
    };

    home.packages = let
      river-run = pkgs.writeShellScriptBin "river-run" ''
        #!/bin/sh

        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=river
        export XDG_CURRENT_DESKTOP=river

        export GDK_BACKEND=wayland
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland-egl
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
        export XCURSOR_SIZE=24
        export NIXOS_OZONE_WL=1

        systemd-cat --identifier=river dbus-run-session river
      '';
    in [
      river-run
    ];
  };

  # system config
  environment.systemPackages = with pkgs; [
    ss.river
    ss.rivercarro
  ];
}
