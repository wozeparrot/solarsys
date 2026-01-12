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

  systemd.user.services.mic-led-watcher = {
    Unit = {
      Description = "Syncs ZBook Mic LED with PipeWire Events";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Restart = "always";
      RestartSec = "3";
      ExecStart = pkgs.writeShellScript "mic-led-watcher" ''
        #!/usr/bin/env bash

        # 1. Locate the LED file dynamically
        LED_FILE=$(find /sys/class/leds -name "*micmute*" -print -quit)

        if [ -z "$LED_FILE" ]; then
          echo "No micmute LED found. Exiting."
          exit 1
        fi

        LED_FILE="$LED_FILE/brightness"

        # 2. Function to check mute state and update LED
        update_led() {
          # Get mute state of the default source (Microphone)
          # Output format is usually "Mute: yes" or "Mute: no"
          IS_MUTED=$(${pkgs.pulseaudio}/bin/pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null)

          if [[ "$IS_MUTED" == *"yes"* ]]; then
            # Muted = LED ON
            echo 1 > "$LED_FILE"
          else
            # Unmuted = LED OFF
            echo 0 > "$LED_FILE"
          fi
        }

        # 3. Initial sync on startup
        update_led

        # 4. Subscribe to events and update on change
        # We listen for 'source' events (mute changes) and 'server' events (default mic changes)
        ${pkgs.pulseaudio}/bin/pactl subscribe | grep --line-buffered -E "on source|on server" | while read -r _; do
          update_led
        done
      '';
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.stateVersion = "22.11";
}
