set ss_json (ss json)
set ss_planets (echo $ss_json | jq -c -r 'keys[]')

# remove file completions
complete -c ssk -f

set -l ssk_commands deploy-all deploy-planet deploy-orbit build-all build-planet build-orbit
set -l ssk_planet_commands deploy-planet build-planet

# command completion
complete -c ssk -n "not __fish_seen_subcommand_from $ssk_commands" -a "$ssk_commands"

# planet completion
complete -c ssk -n "__fish_seen_subcommand_from $ssk_planet_commands; and not __fish_seen_subcommand_from $ss_planets" -a "$ss_planets"
