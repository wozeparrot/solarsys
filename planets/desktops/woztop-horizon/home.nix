{ config, pkgs, ... }:

{
  imports = [
    ../common/home.nix
  ];

  # Packages
  home.packages = with pkgs; [
    docker-compose

    radeontop

    (
      pkgs.writeShellScriptBin "run_gpu" ''
        #!/usr/bin/env bash

        DRI_PRIME=1 exec -a "$0" "$@"
      ''
    )
  ];

  home.stateVersion = "22.11";
}
