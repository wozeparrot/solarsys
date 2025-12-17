#!/usr/bin/env bash
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/framework.bash"

function monitor_hotplug() {
  info "running monitor_hotplug"

  current_sig=$(get_monitors_signature "$(hyprctl -j monitors | jq -j 'map(.description)')")
  info "current monitors signature: $current_sig"

  for file in "$CONFIG_DIR/monitor-hotplug.d"/*.json; do
    [[ -f "$file" ]] || continue

    file_sig=$(get_monitors_signature "$(jq -j '.monitors' "$file")")
    info "checking monitor hotplug config: $(basename "$file") with signature: $file_sig"

    if [[ "$current_sig" == "$file_sig" ]]; then
      info "applying monitor hotplug config: $(basename "$file")"
      eval "$(jq -r '.commands[]' "$file")"
      return 0
    fi
  done
}

function handle() {
  debug "handle: $line"

  case $1 in
    monitoradded*)
      monitor_hotplug
    ;;
    monitorremoved*)
      monitor_hotplug
    ;;
  esac
}

function init() {
  info "running init"

  monitor_hotplug
}

init

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
