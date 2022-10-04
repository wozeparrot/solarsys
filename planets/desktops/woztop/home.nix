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

    gnome.file-roller

    radeontop
    simplescreenrecorder

    teams

    wine64

    (
      pkgs.writeShellScriptBin "run_gpu" ''
        #!/usr/bin/env bash

        DRI_PRIME=1 exec -a "$0" "$@"
      ''
    )
  ];

  # Services
  services.kdeconnect.indicator = true;

  home.stateVersion = "20.09";
}
