complete -c dune \
    -n "not __fish_seen_subcommand_from (_complete_dune_args)" \
    -xa "(_complete_dune_args)"

complete -c dune \
    -n "__fish_seen_subcommand_from show" \
    -xa "(_complete_dune_args show)"

complete -c dune \
    -n "__fish_seen_subcommand_from init" \
    -xa "(_complete_dune_args init)"

complete -c dune \
    -n "__fish_seen_subcommand_from exec" \
    -xa "(_complete_dune_exec_args)"

function _complete_dune_exec_args
    set -l arg (commandline -ct)
    if string match -qr '^\./' "$arg"
        ag -g _build/default | string replace '_build/default' '.'
    end
    echo 'utop'
end

function _complete_dune_args
    set -l FORMAT 'dune: required COMMAND name is missing, must be one of (.*)\.$'
    dune $argv 2>&1 \
        | string replace -rf $FORMAT '$1' \
        | string split ', ' \
        | string split ' or ' \
        | string replace -a "'" ''
end
