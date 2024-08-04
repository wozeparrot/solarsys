{ config, pkgs, ... }:
{
  imports = [ ../common/home.nix ];

  # Packages
  home.packages = with pkgs; [
    docker-compose

    radeontop
    amdgpu_top

    kanshi

    (writeShellScriptBin "run_gpu" ''
      #!/usr/bin/env bash

      DRI_PRIME=1 exec -a "$0" "$@"
    '')

    (writeShellScriptBin "run_gamescope" ''
      #!/usr/bin/env bash

      exec gamescope --prefer-vk-device 1002:1681 -f -U -- "$@"
    '')
  ];

  # kanshi
  services.kanshi = {
    enable = true;
    package = pkgs.nixpkgs-wayland.kanshi;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-2";
            position = "0,0";
          }
        ];
        profile.exec = [
          "$HOME/scripts/clamp_workspaces.sh"
        ];
      }
      {
        profile.name = "docked-home";
        profile.outputs = [
          {
            criteria = "eDP-2";
            position = "0,1080";
          }
          {
            criteria = "Samsung Electric Company S24B240 HTNCB00984";
            mode = "1920x1080@75";
            position = "0,0";
            transform = "normal";
          }
        ];
      }
      {
        profile.name = "docked-away";
        profile.outputs = [
          {
            criteria = "eDP-2";
            position = "0,1080";
          }
          {
            criteria = "Samsung Electric Company SAMSUNG 0x01000E00";
            position = "0,0";
            transform = "normal";
          }
        ];
      }
      {
        profile.name = "docked-away-vertical";
        profile.outputs = [
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
      }
      {
        profile.name = "comma";
        profile.outputs = [
          {
            criteria = "eDP-2";
            position = "0,0";
          }
          {
            criteria = "Dell Inc. DELL U3219Q 1D093Q2";
            position = "1920,0";
            scale = 1.5;
            transform = "normal";
          }
        ];
      }
    ];
  };
  # add packages to the path
  systemd.user.services.kanshi.Service = {
    Environment =
      let
        path = with pkgs; "${bash}/bin:${jq}/bin:${hyprland.hyprland}/bin";
      in
      "PATH=${path}";
  };

  home.stateVersion = "22.11";
}
