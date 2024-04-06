function mkrt --description 'Make a random temporary directory'
    switch $argv[1]
        case make
            set -l dir (mktemp -d /tmp/pg-XXXX)
            ln -s -f $dir /tmp/pg-latest
            pushd $dir
        case _complete
            set -l code (functions (status current-function) | string collect)
            string match -r -a -q '\s*case (?<subcommands>[^_\'](\w|\.)+)' -- $code
            complete -c (status current-function) \
                -n "not __fish_seen_subcommand_from $subcommands" \
                -xa "$subcommands"
        case '*'
            mkrt make
    end
end
