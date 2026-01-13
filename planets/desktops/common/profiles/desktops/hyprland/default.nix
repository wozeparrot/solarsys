{ config, pkgs, ... }:
{
  imports = [ ../common/wayland ];

  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hypr/hyprland.conf" = {
      text =
        (builtins.readFile ./hyprland.conf)
        + ''''
        + (
          let
            rgb = color: "rgb(${color})";
            rgba = color: alpha: "rgba(${color}${alpha})";
          in
          with config.lib.stylix.colors;
          ''
            general {
              col.active_border=${rgb base0D}
              col.inactive_border=${rgb base03}
            }
          ''
        );
      onChange = ''
        (
          XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          if [[ -d "/tmp/hypr" || -d "$XDG_RUNTIME_DIR/hypr" ]]; then
            for i in $(${pkgs.hyprland.hyprland}/bin/hyprctl instances -j | jq ".[].instance" -r); do
              ${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" reload config-only
              # ${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" hyprpaper wallpaper ,$(${pkgs.hyprland.hyprland}/bin/hyprctl -i "$i" hyprpaper listactive | head -n1 | grep -oP '/.*')
            done
          fi
        )
      '';
    };

    home.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_CURRENT_DESKTOP = "Hyprland";

      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;wayland-egl;xcb";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";

      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XCURSOR_SIZE = "24";

      HYPRCURSOR_THEME = "phinger-cursors-light";
      HYPRCURSOR_SIZE = "24";
    };
    xdg.configFile."uwsm/env".source =
      "${config.home-manager.users.woze.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

    services.hyprpolkitagent.enable = false;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = [
          {
            timeout = 180;
            on-timeout = "hyprlock";
          }
        ];
      };
    };

    systemd.user.services.hyprland-bar-toggle = {
      Unit = {
        Description = "Toggles bar on super";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Restart = "always";
        RestartSec = "3";
        ExecStart =
          let
            script =
              pkgs.writers.writePython3Bin "hyprland-bar-toggle"
                {
                  libraries = [ pkgs.python3Packages.evdev ];
                  flakeIgnore = [
                    "E111"
                    "E114"
                    "E265"
                    "E302"
                    "E261"
                    "E501"
                  ];
                }
                ''
                  #!/usr/bin/env python3
                  import asyncio
                  import evdev
                  import subprocess

                  # --- Configuration ---
                  SHOW_SCRIPT = "hyprland-bar-show"
                  HIDE_SCRIPT = "hyprland-bar-hide"
                  POLL_INTERVAL = 3  # Seconds between checking for new devices

                  # Store active tasks: path -> task_object
                  active_tasks = {}

                  def run_script(script_path):
                    """Helper to run the bash scripts without blocking."""
                    subprocess.Popen([script_path])

                  async def handle_device(device_path):
                    """Async loop that reads events from a single device."""
                    try:
                      device = evdev.InputDevice(device_path)
                      print(f"Connected: {device.name}")

                      async for event in device.async_read_loop():
                        if event.type == evdev.ecodes.EV_KEY:
                          # Check for Left Windows Key (KEY_LEFTMETA = 125)
                          if event.code == evdev.ecodes.KEY_LEFTMETA:
                            if event.value == 1:   # Key Down
                              run_script(SHOW_SCRIPT)
                            elif event.value == 0: # Key Up
                              run_script(HIDE_SCRIPT)

                    except OSError:
                      pass # Device disconnected, loop ends automatically
                    finally:
                      print(f"Disconnected: {device_path}")
                      # Safety: If keyboard is yanked, force hide to prevent stuck bar
                      run_script(HIDE_SCRIPT)

                  async def monitor_devices():
                    """Poller to detect new or removed devices."""
                    while True:
                      try:
                        # Get current list of /dev/input/event* paths
                        current_paths = set(evdev.list_devices())

                        # 1. Add new devices
                        for path in current_paths:
                          if path not in active_tasks:
                            try:
                              dev = evdev.InputDevice(path)
                              # Filter: strict check for 'keyboard' in name to avoid mice/headsets
                              if "keyboard" in dev.name.lower():
                                task = asyncio.create_task(handle_device(path))
                                active_tasks[path] = task
                              else:
                                dev.close()
                            except OSError:
                              pass

                        # 2. Cleanup removed devices (tasks that finished)
                        # We iterate a copy of keys to safely modify the dict
                        for path in list(active_tasks.keys()):
                          if active_tasks[path].done():
                            del active_tasks[path]

                      except Exception as e:
                        print(f"Monitor error: {e}")

                      await asyncio.sleep(POLL_INTERVAL)

                  if __name__ == "__main__":
                    try:
                      asyncio.run(monitor_devices())
                    except KeyboardInterrupt:
                      pass
                '';
          in
          "${script}/bin/hyprland-bar-toggle";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.hyprbash = {
      Unit = {
        Description = "bash plugin system for hyprland ipc";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Restart = "always";
        RestartSec = "3";
        ExecStart =
          let
            hyprbash = pkgs.stdenv.mkDerivation {
              pname = "hyprbash";
              version = "0.1.0";

              src = ./hyprbash;

              buildInputs = with pkgs; [
                socat
                inotify-tools
              ];

              installPhase = ''
                mkdir -p $out/bin
                cp -r ./* $out/bin/
              '';
            };
          in
          "${hyprbash}/bin/hyprbash.sh";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # system config
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "hyprland-gamemode" ''
      #!/usr/bin/env sh
      HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
      if [ "$HYPRGAMEMODE" == 1 ] ; then
          hyprctl --batch "\
              keyword animations:enabled 0;\
              keyword decoration:shadow:enabled 0;\
              keyword decoration:blur:enabled 0;\
              keyword general:gaps_in 0;\
              keyword general:gaps_out 0;\
              keyword general:border_size 0;\
              keyword decoration:rounding 0"
          exit
      fi
      hyprctl reload
    '')
    (pkgs.writeShellScriptBin "hyprland-bar-hide" ''
      #!/usr/bin/env bash

      # Check if waybar is in Top (2) or Overlay (3) layers
      is_visible=$(hyprctl layers -j | ${pkgs.jq}/bin/jq -e ".[] | .levels[\"2\"][]?, .levels[\"3\"][]? | select(.namespace == \"waybar\")")

      if [ -n "$is_visible" ]; then
        pkill -SIGUSR1 waybar
      fi

      hyprctl keyword workspace w[tv1], gapsout:0
    '')
    (pkgs.writeShellScriptBin "hyprland-bar-show" ''
      #!/usr/bin/env bash

      # Check if waybar is in Top (2) or Overlay (3) layers
      is_visible=$(hyprctl layers -j | ${pkgs.jq}/bin/jq -e ".[] | .levels[\"2\"][]?, .levels[\"3\"][]? | select(.namespace == \"waybar\")")

      if [ -z "$is_visible" ]; then
        pkill -SIGUSR1 waybar
      fi

      hyprctl keyword workspace w[tv1], gapsout:16
    '')
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.hyprland.hyprland;
    portalPackage = pkgs.hyprland.xdg-desktop-portal-hyprland;
  };
}
