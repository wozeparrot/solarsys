{ config, pkgs, ... }:
{
  imports = [ ../common/home.nix ];

  # Packages
  home.packages = with pkgs; [
    docker-compose

    radeontop
    amdgpu_top

    nixpkgs-wayland.kanshi

    (writeShellScriptBin "run_gpu" ''
      #!/usr/bin/env bash

      DRI_PRIME=1 exec -a "$0" "$@"
    '')

    (writeShellScriptBin "run_gamescope" ''
      #!/usr/bin/env bash

      exec gamescope --prefer-vk-device 1002:1681 -f -U -- "$@"
    '')
  ];

  programs.btop.package = pkgs.btop-rocm;

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
            position = "0,0";
          }
          {
            criteria = "LG Electronics LG ULTRAGEAR 406NTQD74260";
            position = "1920,0";
            transform = "normal";
          }
          {
            criteria = "BOE J560T09 Unknown";
            position = "1920,1440";
            transform = "normal";
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
