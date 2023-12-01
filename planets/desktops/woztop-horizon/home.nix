{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/home.nix
  ];

  # Packages
  home.packages = with pkgs; [
    docker-compose

    radeontop
    amdgpu_top

    kanshi

    (
      pkgs.writeShellScriptBin "run_gpu" ''
        #!/usr/bin/env bash

        DRI_PRIME=1 exec -a "$0" "$@"
      ''
    )

    (
      pkgs.writeShellScriptBin "run_gamescope" ''
        #!/usr/bin/env bash

        exec gamescope --prefer-vk-device 1002:1681 -f -U -- "$@"
      ''
    )
  ];

  # kanshi
  services.kanshi = {
    enable = true;
    package = pkgs.nixpkgs-wayland.kanshi;
    systemdTarget = "graphical-session.target";
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-2";
            position = "0,0";
          }
        ];
        exec = [
          "$HOME/scripts/clamp_workspaces.sh"
          "swww img ${../common/misc/wallpaper.png}"
        ];
      };
      docked-home = {
        outputs = [
          {
            criteria = "eDP-2";
            position = "0,1080";
          }
          {
            criteria = "Samsung Electric Company S24B240 HTNCB00984";
            # mode = "1920x1080@75"; # TODO: when kanshi supports custom modes
            position = "0,0";
            transform = "normal";
          }
        ];
        exec = [
          "swww img ${../common/misc/wallpaper.png}"
        ];
      };
      docked-away = {
        outputs = [
          {
            criteria = "eDP-2";
            position = "0,0";
          }
          {
            criteria = "Samsung Electric Company SAMSUNG 0x01000E00";
            position = "1920,0";
            transform = "normal";
          }
        ];
        exec = [
          "swww img ${../common/misc/wallpaper.png}"
        ];
      };
      docked-away-vertical = {
        outputs = [
          {
            criteria = "eDP-2";
            position = "0,720";
          }
          {
            criteria = "Samsung Electric Company SAMSUNG 0x01000E00";
            position = "1920,0";
            transform = "90";
          }
        ];
        exec = [
          "swww img ${../common/misc/wallpaper.png}"
        ];
      };
    };
  };
  # add packages to the path
  systemd.user.services.kanshi.Service = {
    Environment = let
      path = with pkgs; "${bash}/bin:${jq}/bin:${hyprland.hyprland}/bin:${swww}/bin";
    in "PATH=${path}";
  };

  home.stateVersion = "22.11";
}
