function autocomplete --description 'example of case-autocompletion'
    switch $argv[1]
        case subcommand1
            echo 1
        case subcommand2
            echo 2
        case subcommand3
            echo 3
        case _complete
            set -l code (functions (status current-function) | string collect)
            string match -r -a -q '\s*case (?<subcommands>[^_]\w+)' -- $code
            complete -c (status current-function) \
                -n "not __fish_seen_subcommand_from $subcommands" \
                -xa "$subcommands"
    end
end
