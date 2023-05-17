#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'

# echo to stderr
function ercho { printf "%s\n" "$*" >&2; }

# echo to stderr with program name
function log {
    local program_name
    program_name="$(basename "$0")"
    ercho "$program_name: $*"
}

# shortcut to return values
function r { printf "%s" "$*"; }

# sleep that counts
function visible_sleep {
    local DELAY=$1

    for i in $(seq "$DELAY" -1 1); do
        for s in / - \\ \|; do
            printf "\r%s = $i        " "$s"
            sleep 0.25
        done
    done
    printf "\r                \r"
}

# prompt user for y or n
function yes_or_no {
    local RETURN=0

    if [[ -n "$ALWAYS_YES" ]]; then
        return "$RETURN"
    fi

    local yn
    read -r -p "$* [Y/n]: " yn
    case $yn in
        [Yy]*) RETURN=0 ;;
        [Nn]*) RETURN=1 ;;
    esac

    return "$RETURN"
}

# prompt for user input
function input {
    local prompt=$1

    local in
    read -r -p "[$prompt]: " in
    r "$in"
}

# retry with exponential backoff
function retry {
    local max="$1"
    shift 1

    local delay=1
    local attempts=1

    while [[ "$attempts" -le "$max" ]]; do
        if "$@"; then
            break
        fi

        if [[ "$attempts" -lt "$max" ]]; then
            echo "Retrying in $delay seconds..."
            visible_sleep "$delay"
        elif [[ "$attempts" -eq "$max" ]]; then
            echo "Failed after $attempts attempts"
            return 1
        fi

        attempts=$((attempts + 1))
        delay=$((delay * 2))
    done
}

# decode url
function url_decode {
    : "${*//+/ }"
    echo -en "${_//%/\\x}"
}

# source common.bash if it exists
if [[ -f "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.bash" ]]; then
    source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.bash"
fi
