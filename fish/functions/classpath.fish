function classpath
    set -l subcommands \
        "setup\t'Set global \$CLASSPATH to \$jars'" \
        "add\t'Select jar from .gradle to track in \$jars'" \
        "reset\t'Clear \$jars'" \
        "list\t'List tracked \$jars'" \
        "help\t'Print this help'"
    switch $argv[1]
        case help
            string replace '\t' '	' $subcommands
        case setup
            set -xg CLASSPATH $jars
        case add
            pushd $HOME/.gradle/
            set -Ua jars (realpath (fzf -m))
            popd
        case reset
            set -Ue jars
            classpath add
        case list
            string collect -- $jars
        case __complete
            complete -c classpath -e
            complete -c classpath \
                -n "not __fish_seen_subcommand_from (fw $subcommands)" \
                -xa "$subcommands"
        case '*'
            echo Missing subcommand! Choose one of:
            string replace '\t' '	' $subcommands
    end
end
