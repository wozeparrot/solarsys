#!/usr/bin/env bash
set -em

# --- utility functions ---
# echo to stderr
function ercho { printf "%s\n" "$*" >&2; }

# shortcut to return values
function r { printf "%s" "$*"; }


# --- script main ---
case "$1" in
    d1) # deploy testing to ensure that nothing if broken
        "$2"/bin/switch-to-configuration test
        bash /tmp/solarsys-remote.sh dt& disown
        exit
        ;;
    d2) # deploy switch
        pkill -f "bash /tmp/solarsys-remote.sh dt"
        nix-env -p /nix/var/nix/profiles/system --set "$2"
        "$2"/bin/switch-to-configuration switch
        ;;
    dt) # deploy testing auto rollback
        sleep 15
        reboot
        ;;
    *) exit ;;
esac
