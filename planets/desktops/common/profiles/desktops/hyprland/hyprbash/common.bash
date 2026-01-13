#!/usr/bin/env bash

# CONFIG_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
CONFIG_DIR="$HOME/.config/hyprbash"

function get_monitors_signature() {
  local monitors=$1
  jq -j 'sort | join("|||")' <<< "$monitors" | sha256sum | awk '{print $1}'
}
