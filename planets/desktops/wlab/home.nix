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

  programs.fish.loginShellInit = ''
    if not set -q WAYLAND_DISPLAY and test "$XDG_VTNR" = "1"
      hyprland-run
    end
  '';

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
