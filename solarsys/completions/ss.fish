set ss_json (ss json)
set ss_planets (echo $ss_json | jq -c -r 'keys[]')

function __fish_complete_ss_moons
    set -l tokens (commandline -opc) (commandline -ct)
    set -l planet $tokens[-2]
    echo $ss_json | jq -c -r ".$planet" | jq -c -r ".[]" 2>/dev/null
    if test $status -ne 0
        set -l planet $tokens[-3]
        echo $ss_json | jq -c -r ".$planet" | jq -c -r ".[]" 2>/dev/null
    end
end

# remove file completions
complete -c ss -f

set -l ss_commands deploy deploy-all deploy-planet deploy-orbit build rollback test ssh satellites list
set -l ss_planet_commands deploy deploy-planet build rollback test ssh satellites
set -l ss_moon_commands deploy build rollback test ssh satellites

# command completion
complete -c ss -n "not __fish_seen_subcommand_from $ss_commands" -a "$ss_commands"

# planet completion
complete -c ss -n "__fish_seen_subcommand_from $ss_planet_commands; and not __fish_seen_subcommand_from $ss_planets" -a "$ss_planets"

# moon completion
complete -c ss -n "__fish_seen_subcommand_from $ss_moon_commands; and __fish_seen_subcommand_from $ss_planets; and not __fish_seen_subcommand_from (__fish_complete_ss_moons)" -a "(__fish_complete_ss_moons)"
