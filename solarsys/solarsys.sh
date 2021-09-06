#!/usr/bin/env bash
set -e

# --- utility functions ---
# echo to stderr
function ercho { printf "%s\n" "$*" >&2; }

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
    if [[ -n "$ALWAYS_YES" ]]; then
        return 0
    fi

    local yn
    while true; do
        read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0 ;;  
            [Nn]*) return 1 ;;
        esac
    done
}


# --- script helper functions ---
# shortcut for nix eval --json --impure --expr
function nee { nix eval --json --impure --expr "$1"; }

# shortcut to flake in pwd
FLK='(builtins.getFlake (builtins.toString ./.))'

# gets planets from flake
function get_planets {
    nee "builtins.attrNames $FLK.planets"
}

# gets moons for a planet
function get_moons {
    local planet=$1
    nee "builtins.attrNames $FLK.planets.$planet.moons"
}

# gets trajectory for a moon
function get_trajectory {
    local planet=$1
    local moon=$2
    nee "$FLK.planets.$planet.moons.$moon.trajectory"
}

# gets orbits for a moon
function get_orbits {
    local planet=$1
    local moon=$2
    nee "$FLK.planets.$planet.moons.$moon.orbits"
}

# checks if planet exists
function has_planet {
    local planet=$1
    if [[ "$(nee "builtins.hasAttr \"$planet\" $FLK.planets")" == "false" ]]; then
        return 1
    else
        return 0
    fi
}

# checks if a moon exists for a planet
function has_moon {
    local planet=$1
    local moon=$2
    if [[ "$(nee "builtins.hasAttr \"$moon\" $FLK.planets.$planet.moons")" == "false" ]]; then
        return 1
    else
        return 0
    fi
}

# builds an output for a moon in a planet
function build_moon_output {
    local planet=$1
    local moon=$2
    local output=$3

    # build
    if nix build --no-link ".#planets.$planet.moons.$moon.core.$output"; then
        nix path-info ".#planets.$planet.moons.$moon.core.$output"
        return 0
    else
        return 1
    fi
}

# sends satellites to a moon in a planet
function send_satellites {
    local planet=$1
    local moon=$2
    local trajectory_host=$3
    local trajectory_port=$4

    # parse satellites
    local satellites
    readarray -t satellites <<< "$(nee "builtins.attrNames $FLK.planets.$planet.moons.$moon.satellites" | jq -c -r '.[]')"

    for satellite in "${satellites[@]}"; do
        local dest_path
        dest_path="$(nee "$FLK.planets.$planet.moons.$moon.satellites.$satellite" | jq -c -r '.destination')"
        if [[ "$dest_path" == "null" ]]; then
            dest_path="/run/keys/"
        fi

        echo "[solarsys] Deploying satellite: |$satellite| to destination: |$dest_path|"

        local path
        path=$(jq -c -r '.path' <<< "$(nee "$FLK.planets.$planet.moons.$moon.satellites.$satellite")")
        if [[ -n "$path" ]]; then
            rsync -q -e "ssh -p $trajectory_port" -r "$path" "root@[$trajectory_host]:$dest_path/$satellite"
            return
        fi
    done
}


# --- script main ---
# -- script main functions --
# deploys a single moon in a planet
function deploy {
    local planet=$1
    local moon=$2

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi
    if ! has_moon "$planet" "$moon"; then
        ercho "error~ Moon: |$moon| does not exist for planet: |$planet|!"
        return 1
    fi

    echo "[solarsys] Deploying moon: |$moon| in planet: |$planet|"

    # check if we are deploying our current system
    if [[ "$moon" == "$(hostname)" ]]; then
        echo "[solarsys] Moon: |$moon| is the current system..."

        # wait for user response
        yes_or_no "[solarsys] Deploy?" || return

        # build and switch to new config
        local buildpath
        if buildpath="$(build_moon_output "$planet" "$moon" "config.system.build.toplevel")"; then
            echo "[solarsys] Press enter to continue..."
            read -r
            sudo bash <<EOF
nix-env -p /nix/var/nix/profiles/system --set "$buildpath"
"$buildpath"/bin/switch-to-configuration switch
EOF
        fi
    else # deploying remotely
        local trajectory
        trajectory="$(get_trajectory "$planet" "$moon")"
        
        if [[ -z "$(jq -c -r '.' <<< "$trajectory")" ]]; then
            ercho "warning~ Moon: |$moon| is set for a local trajectory, skipping."
            return
        fi

        local trajectory_host trajectory_port
        trajectory_host="$(jq -c -r '.host' <<< "$trajectory")"
        trajectory_port="$(jq -c -r '.port' <<< "$trajectory")"

        echo "[solarsys] Moon: |$moon| is at |$trajectory_host| on port |$trajectory_port|"
        
        # build config
        local buildpath
        if buildpath="$(build_moon_output "$planet" "$moon" "config.system.build.toplevel")"; then
            # copy built config
            nix copy --to "ssh://root@$trajectory_host" "$buildpath"
            # copy remote deploy script
            rsync -q -e "ssh -p $trajectory_port" "$(dirname "$0")/solarsys-remote.sh" "root@[$trajectory_host]:/tmp/solarsys-remote.sh"
            # send satellites
            send_satellites "$planet" "$moon" "$trajectory_host" "$trajectory_port"

            # deploy stage1 - testing config
            ssh -t "root@$trajectory_host" -p "$trajectory_port" "bash /tmp/solarsys-remote.sh d1 $buildpath" 2> /dev/null
            # wait to see if we can still connect
            echo "[solarsys] Waiting for reconnection..."
            visible_sleep 5
            # deploy stage2 - real deploy
            ssh -t "root@$trajectory_host" -p "$trajectory_port" "bash /tmp/solarsys-remote.sh d2 $buildpath" 2> /dev/null
            echo "[solarsys] Deployed moon: |$moon|"
        fi
    fi
}

# deploys all moons
function deploy_all {
    echo "[solarsys] Deploying all moons"
    
    local planets
    readarray -t planets <<< "$(get_planets | jq -c -r '.[]')"

    for planet in "${planets[@]}"; do
        local moons
        readarray -t moons <<< "$(get_moons "$planet" | jq -c -r '.[]')"

        for moon in "${moons[@]}"; do
            if [[ -z "$moon" ]]; then
                break
            fi
            
            deploy "$planet" "$moon"
        done
    done
}

# deploys all moons in a planet
function deploy_planet {
    local planet=$1

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi

    echo "[solarsys] Deploying all moons in planet: |$planet|"

    local moons
    readarray -t moons <<< "$(get_moons "$planet" | jq -c -r '.[]')"

    for moon in "${moons[@]}"; do
        if [[ -z "$moon" ]]; then
            break
        fi
            
        deploy "$planet" "$moon"
    done
}

# deploys all moons with an orbit
function deploy_orbit {
    local orbit=$1

    echo "[solarsys] Deploying all moons with orbit: |$orbit|"

    local planets
    readarray -t planets <<< "$(get_planets | jq -c -r '.[]')"

    for planet in "${planets[@]}"; do
        local moons
        readarray -t moons <<< "$(get_moons "$planet" | jq -c -r '.[]')"

        for moon in "${moons[@]}"; do
            if [[ -z "$moon" ]]; then
                break
            fi

            local orbits
            readarray -t orbits <<< "$(get_orbits "$planet" "$moon" | jq -c -r '.[]')"

            if [[ ! "$(printf "_[%s]_" "${orbits[@]}")" =~ .*_\[$orbit\]_.* ]]; then
                continue
            fi
            
            deploy "$planet" "$moon"
        done
    done
}

# builds an output for a moon in a planet
function build {
    local planet=$1
    local moon=$2
    local output=$3

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi
    if ! has_moon "$planet" "$moon"; then
        ercho "error~ Moon: |$moon| does not exist for planet: |$planet|!"
        return 1
    fi

    echo "[solarsys] Building output: |$output| for moon: |$moon| in planet: |$planet|"

    build_moon_output "$planet" "$moon" "$output"
}

# rolls back a moon in a planet
function rollback {
    local planet=$1
    local moon=$2

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi
    if ! has_moon "$planet" "$moon"; then
        ercho "error~ Moon: |$moon| does not exist for planet: |$planet|!"
        return 1
    fi

    echo "[solarsys] Rolling back moon: |$moon| in planet: |$planet|"

    # check if we are testing our current system
    if [[ "$moon" == "$(hostname)" ]]; then
        echo "[solarsys] Moon: |$moon| is the current system..."

        # wait for user response
        yes_or_no "Rollback?" || return

        # rollback
        sudo bash <<EOF
nix-env -p /nix/var/nix/profiles/system --rollback
/nix/var/nix/profiles/system/bin/switch-to-configuration switch
EOF
    else # rolling back remotely
        local trajectory
        trajectory="$(get_trajectory "$planet" "$moon")"
        
        if [[ -z "$(jq -c -r '.' <<< "$trajectory")" ]]; then
            ercho "warning~ Moon: |$moon| is set for a local trajectory, skipping."
            return
        fi

        local trajectory_host trajectory_port
        trajectory_host="$(jq -c -r '.host' <<< "$trajectory")"
        trajectory_port="$(jq -c -r '.port' <<< "$trajectory")"

        echo "[solarsys] Moon: |$moon| is at |$trajectory_host| on port |$trajectory_port|"
    fi
}

# tests a single moon in a planet
function test_moon {
    local planet=$1
    local moon=$2

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi
    if ! has_moon "$planet" "$moon"; then
        ercho "error~ Moon: |$moon| does not exist for planet: |$planet|!"
        return 1
    fi

    echo "[solarsys] Testing moon: |$moon| in planet: |$planet|"

    # check if we are testing our current system
    if [[ "$moon" == "$(hostname)" ]]; then
        echo "Moon: |$moon| is the current system..."

        # wait for user response
        yes_or_no "Test?" || return

        # build and test new config
        local buildpath
        if buildpath="$(build_moon_output "$planet" "$moon" "config.system.build.toplevel")"; then
            echo "[solarsys] Press enter to continue..."
            read -r
            sudo "$buildpath"/bin/switch-to-configuration test
        fi
    else # testing remotely
        local trajectory
        trajectory="$(get_trajectory "$planet" "$moon")"
        
        if [[ -z "$(jq -c -r '.' <<< "$trajectory")" ]]; then
            ercho "warning~ Moon: |$moon| is set for a local trajectory, skipping."
            return
        fi

        local trajectory_host trajectory_port
        trajectory_host="$(jq -c -r '.host' <<< "$trajectory")"
        trajectory_port="$(jq -c -r '.port' <<< "$trajectory")"

        echo "[solarsys] Moon: |$moon| is at |$trajectory_host| on port |$trajectory_port|"
    fi
}

# ssh to a moon in a planet
function ssh_moon {
    local planet=$1
    local moon=$2

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi
    if ! has_moon "$planet" "$moon"; then
        ercho "error~ Moon: |$moon| does not exist for planet: |$planet|!"
        return 1
    fi

    # check if the moon we are trying to connect to is the current system
    if [[ "$moon" == "$(hostname)" ]]; then
        ercho "error~ Moon: |$moon| is the current system!"
    else
        local trajectory
        trajectory="$(get_trajectory "$planet" "$moon")"
        
        if [[ -z "$(jq -c -r '.' <<< "$trajectory")" ]]; then
            ercho "error~ Moon: |$moon| does not have a set trajectory!"
            return 1
        fi

        local trajectory_host trajectory_port
        trajectory_host="$(jq -c -r '.host' <<< "$trajectory")"
        trajectory_port="$(jq -c -r '.port' <<< "$trajectory")"

        echo "[solarsys] Moon: |$moon| is at |$trajectory_host| on port |$trajectory_port|"
        exec ssh "root@$trajectory_host" -p "$trajectory_port" 
    fi
}

# send satellites to a moon in a planet
function satellites {
    local planet=$1
    local moon=$2

    # sanity check
    if ! has_planet "$planet"; then
        ercho "error~ Planet: |$planet| does not exist!"
        return 1
    fi
    if ! has_moon "$planet" "$moon"; then
        ercho "error~ Moon: |$moon| does not exist for planet: |$planet|!"
        return 1
    fi

    # check if the moon we are trying to connect to is the current system
    if [[ "$moon" == "$(hostname)" ]]; then
        ercho "error~ Moon: |$moon| is the current system!"
    else
        local trajectory
        trajectory="$(get_trajectory "$planet" "$moon")"
        
        if [[ -z "$(jq -c -r '.' <<< "$trajectory")" ]]; then
            ercho "error~ Moon: |$moon| does not have a set trajectory!"
            return 1
        fi

        local trajectory_host trajectory_port
        trajectory_host="$(jq -c -r '.host' <<< "$trajectory")"
        trajectory_port="$(jq -c -r '.port' <<< "$trajectory")"

        echo "[solarsys] Moon: |$moon| is at |$trajectory_host| on port |$trajectory_port|"
        send_satellites "$planet" "$moon" "$trajectory_host" "$trajectory_port"
    fi
}

# lists planets and moons
function list {
    local planets
    readarray -t planets <<< "$(get_planets | jq -c -r '.[]')"

    for planet in "${planets[@]}"; do
        echo "$planet"

        local moons
        readarray -t moons <<< "$(get_moons "$planet" | jq -c -r '.[]')"

        for i in "${!moons[@]}"; do
            if [[ -z "${moons[i]}" ]]; then
                break
            fi

            local trajectory
            trajectory="$(get_trajectory "$planet" "${moons[i]}")"
            
            if [[ -z "$(jq -c -r '.' <<< "$trajectory")" ]]; then
                trajectory="local"
            fi

            if [[ "$((i + 1))" == "${#moons[@]}" ]]; then
                echo "└───${moons[i]} at $trajectory"
            else
                echo "├───${moons[i]} at $trajectory"
            fi
        done

        echo
    done
}

# prints usage of solarsys
function print_usage {
    ercho "Usage: $0 <subcommand>"
    ercho
    ercho "  Subcommand                     |  Description"
    ercho "--------------------------------------------------------------------------"
    ercho "  deploy <planet> <moon>         |  Deploys <moon> in <planet>"
    ercho "  deploy-all                     |  Deploys all moons"
    ercho "  deploy-planet <planet>         |  Deploys all moons in <planet>"
    ercho "  deploy-orbit <orbit>           |  Deploys all moons with <orbit>"
    ercho "  build <planet> <moon> <output> |  Builds <output> for <moon> in <planet>"
    ercho "  rollback <planet> <moon>       |  Rolls back <moon> in <planet>"
    ercho "  test <planet> <moon>           |  Tests <moon> in <planet>"
    ercho "  ssh <planet> <moon>            |  SSH to <moon> in <planet>"
    ercho "  satellites <planet> <moon>     |  Send satellites to <moon> in <planet>"
    ercho "  list                           |  Lists planets and moons"
    exit 1
}

# main function
function main {
    # check if subcommand is set
    local subcommand=$1
    if [[ -z "$subcommand" ]]; then
        print_usage
    fi

    # switch on subcommand
    case "$subcommand" in
        deploy)
            local planet=$2
            local moon=$3
            if [[ -z "$planet" ]] || [[ -z "$moon" ]]; then
                ercho "error~ No planet and/or moon specified"
                ercho
                print_usage
            fi

            deploy "$planet" "$moon"
            ;;
        deploy-all)
            deploy_all
            ;;
        deploy-planet)
            local planet=$2
            if [[ -z "$planet" ]]; then
                ercho "error~ No planet specified"
                ercho
                print_usage
            fi

            deploy_planet "$planet"
            ;;
        deploy-orbit)
            local orbit=$2
            if [[ -z "$orbit" ]]; then
                ercho "error~ No orbit specified"
                ercho
                print_usage
            fi

            deploy_orbit "$orbit"
            ;;
        build)
            local planet=$2
            local moon=$3
            local output=$4
            if [[ -z "$planet" ]] || [[ -z "$moon" ]] || [[ -z "$output" ]]; then
                ercho "error~ No planet, moon, and/or output specified"
                ercho
                print_usage
            fi

            build "$planet" "$moon" "$output"
            ;;

        rollback)
            local planet=$2
            local moon=$3
            if [[ -z "$planet" ]] || [[ -z "$moon" ]]; then
                ercho "error~ No planet and/or moon specified"
                ercho
                print_usage
            fi

            rollback "$planet" "$moon"
            ;;
        test)
            local planet=$2
            local moon=$3
            if [[ -z "$planet" ]] || [[ -z "$moon" ]]; then
                ercho "error~ No planet and/or moon specified"
                ercho
                print_usage
            fi

            test_moon "$planet" "$moon"
            ;;
        ssh)
            local planet=$2
            local moon=$3
            if [[ -z "$planet" ]] || [[ -z "$moon" ]]; then
                ercho "error! No planet and/or moon specified"
                ercho
                print_usage
            fi

            ssh_moon "$planet" "$moon"
            ;;
        satellites)
            local planet=$2
            local moon=$3
            if [[ -z "$planet" ]] || [[ -z "$moon" ]]; then
                ercho "error! No planet and/or moon specified"
                ercho
                print_usage
            fi

            satellites "$planet" "$moon"
            ;;
        list)
            list
            ;;
        *)
            ercho "error~ Unknown subcommand: $subcommand"
            ercho
            print_usage
            ;;
    esac
}

# run main
main "$@"
