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

  home.stateVersion = "25.11";
}
