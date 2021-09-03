#!/usr/bin/env bash
set -e

# --- utility functions ---
# echo to stderr
function ercho { printf "%s\n" "$*" >&2; }

# shortcut to return values
function r { printf "%s" "$*"; }


# --- script main ---

