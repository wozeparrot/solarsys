{ config, pkgs, ... }:
{
  imports = [ ../common/home.nix ];

  # Packages
  home.packages = with pkgs; [
    docker-compose

    radeontop
    amdgpu_top

    (writeShellScriptBin "run_gpu" ''
      #!/usr/bin/env bash

      DRI_PRIME=1 exec -a "$0" "$@"
    '')

    (writeShellScriptBin "run_gamescope" ''
      #!/usr/bin/env bash

      exec gamescope -f -U -- "$@"
    '')
  ];

  programs.btop.package = pkgs.btop-rocm;

  home.stateVersion = "22.11";
}
