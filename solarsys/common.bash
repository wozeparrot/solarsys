#!/usr/bin/env bash

FLK="$(nix --extra-experimental-features "nix-command flakes" $NIX_EXTRA_OPTS eval .#planets --json --apply "(builtins.getFlake \"git+file://\${toString ./.}?rev=$(git rev-parse HEAD)\").lib.attrsets.filterAttrsRecursive (n: v: n != \"core\")")"

# gets planets from flake
function get_planets {
    jq -c -r 'keys' <<< "$FLK"
}

# gets moons for a planet
function get_moons {
    local planet=$1
    jq -c -r ".\"$planet\".moons | keys" <<< "$FLK"
}

# gets trajectory for a moon
function get_trajectory {
    local planet=$1
    local moon=$2
    jq -c -r ".\"$planet\".moons.\"$moon\".trajectory" <<< "$FLK"
}

# gets orbits for a moon
function get_orbits {
    local planet=$1
    local moon=$2
    jq -c -r ".\"$planet\".moons.\"$moon\".orbits" <<< "$FLK"
}

# checks if planet exists
function has_planet {
    local planet=$1
    if [[ "$(jq -e "has(\"$planet\")" <<< "$FLK" )" == "false" ]]; then
        return 1
    else
        return 0
    fi
}

# checks if a moon exists for a planet
function has_moon {
    local planet=$1
    local moon=$2
    if [[ "$(jq -e ".\"$planet\".moons | has(\"$moon\")" <<< "$FLK" )" == "false" ]]; then
        return 1
    else
        return 0
    fi
}

function get_satellites {
    local planet=$1
    local moon=$2
    jq -c -r ".\"$planet\".moons.\"$moon\".satellites" <<< "$FLK"
}

# builds an output for a moon in a planet
function build_moon_output {
    local planet=$1
    local moon=$2
    local output=$3

    # build
    local build_cmd="nix --extra-experimental-features \"nix-command flakes\" $NIX_EXTRA_OPTS build --log-format internal-json -v --no-link \".#planets.$planet.moons.$moon.core.$output\" |& nom --json"

    if eval "$build_cmd"; then
        nix --experimental-features "nix-command flakes" --extra-experimental-features "nix-command flakes" path-info ".#planets.$planet.moons.$moon.core.$output"
        return 0
    else
        return 1
    fi
}

# sends satellites to a moon in a planet
function send_satellites_ {
    local trajectory_host=$1
    local trajectory_port=$2
    local dest_path=$3
    local path=$4
    local chown_target=$5

    echo "[solarsys] Deploying satellite: |$name| to destination: |$dest_path|"
    ssh -t "root@$trajectory_host" -p "$trajectory_port" "mkdir -p $(dirname "$dest_path")" 2> /dev/null
    rsync -q -e "ssh -p $trajectory_port" -r "$path" "root@[$trajectory_host]:$dest_path"

    if [[ -n "$chown_target" && ! "$chown_target" == "null" ]]; then
        echo "[solarsys] Chowning satellite: |$dest_path| to: |$chown_target|"
        ssh -t "root@$trajectory_host" -p "$trajectory_port" "chown $chown_target $dest_path" 2> /dev/null
    fi
}

function send_satellites {
    local planet=$1
    local moon=$2
    local trajectory_host=$3
    local trajectory_port=$4

    # parse satellites
    local satellites
    readarray -t satellites <<< "$(get_satellites "$planet" "$moon" | jq -c -r 'to_entries | .[]')"

    for satellite in "${satellites[@]}"; do
        local name
        name="$(jq -c -r '.key' <<< "$satellite")"

        local dest_path
        dest_path="$(jq -c -r '.value.destination' <<< "$satellite")"
        if [[ "$dest_path" == "null" ]]; then
            dest_path="/run/keys/$satellite"
        fi

        local path
        path="$(jq -c -r '.value.path' <<< "$satellite")"
        if [[ -n "$path" && ! "$path" == "null" ]]; then
            local chown_target
            chown_target="$(jq -c -r '.value.chown' <<< "$satellite")"

            send_satellites_ "$trajectory_host" "$trajectory_port" "$dest_path" "$path" "$chown_target" &
        fi
    done

    wait
}
