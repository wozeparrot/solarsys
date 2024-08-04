{ config, pkgs, ... }:
{
  imports = [ ../common/home.nix ];

  # Packages
  home.packages = with pkgs; [
    radeontop
    amdgpu_top

    (writeShellScriptBin "run_gpu" ''
      #!/usr/bin/env bash

      exec -a "$0" "$@"
    '')

    (writeShellScriptBin "run_gamescope" ''
      #!/usr/bin/env bash

      exec gamescope -f -U -- "$@"
    '')
  ];

  home.stateVersion = "24.05";
}
