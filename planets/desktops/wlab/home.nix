{ config, pkgs, ... }:
{
  imports = [ ../common/home.nix ];

  # Packages
  home.packages = with pkgs; [
    (writeShellScriptBin "run_gpu" ''
      #!/usr/bin/env bash

      exec -a "$0" "$@"
    '')

    (writeShellScriptBin "run_gamescope" ''
      #!/usr/bin/env bash

      exec gamescope -f -U -- "$@"
    '')
  ];

  services.wayvnc = {
    enable = true;
    autoStart = true;
    settings = {
      address = "127.0.0.1";
      port = 5900;
    };
  };

  # kanshi
  services.kanshi = {
    enable = true;
    package = pkgs.nixpkgs-wayland.kanshi;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "dummy";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            mode = "1920x1080@60";
            position = "0,0";
            scale = 1.;
            transform = "normal";
          }
        ];
      }
      {
        profile.name = "viture-pro";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            mode = "1920x1080@60";
            position = "0,0";
            scale = 1.;
            transform = "normal";
          }
          {
            criteria = "CVT VITURE 0x88888800";
            mode = "1920x1080@120";
            position = "1920,0";
            scale = 1.;
            transform = "normal";
          }
        ];
      }
    ];
  };

  home.stateVersion = "25.11";
}
