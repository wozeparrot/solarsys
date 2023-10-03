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
    xdg.configFile."hypr/hyprland.conf" = {
      source = ./hyprland.conf;
      onChange = "HYPRLAND_INSTANCE_SIGNATURE=$(ls -w 1 /tmp/hypr | tail -1) ${pkgs.hyprland.hyprland}/bin/hyprctl reload config-only}";
    };
  };

  # system config
  environment.systemPackages = with pkgs; [
    hyprland.hyprland
    (pkgs.writeShellScriptBin "hl-switchworkspacetoactivemonitor" (let
      try_swap_workspace = pkgs.hyprland-contrib.try_swap_workspace.overrideAttrs (_: {
        postPatch = ''
          substituteInPlace try_swap_workspace --replace "-x Hyprland" "Hyprland"
        '';
      });
    in ''
      ${try_swap_workspace}/bin/try_swap_workspace "$1"
    ''))
  ];

  xdg.portal = {
    extraPortals = [
      (pkgs.xdph.xdg-desktop-portal-hyprland.override {
          inherit (pkgs.hyprland) hyprland;
      })
    ];
  };

  services.greetd = {
    settings = {
      default_session = {
        command = let
          hyprland-run = pkgs.writeShellScriptBin "hyprland-run" ''
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

            exec systemd-cat --identifier=hyprland dbus-run-session Hyprland
          '';
        in "${pkgs.greetd.tuigreet}/bin/tuigreet --time --greeting 'Access is restricted to authorized personnel only.' --cmd ${hyprland-run}/bin/hyprland-run";
      };
    };
  };
}
