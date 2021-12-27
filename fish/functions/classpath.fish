function classpath --description '$CLASSPATH management'
    switch $argv[1]
        case help
            string collect -- \
                "setup	'Set global \$CLASSPATH to \$jars'" \
                "add	'Select jar from .gradle to track in \$jars'" \
                "reset	'Clear \$jars'" \
                "list	'List tracked \$jars'" \
                "help	'Print this help'"
        case setup
            set -xg CLASSPATH $jars
        case add
            pushd $HOME/.gradle/
            set -Ua jars (realpath (fzf -m))
            popd
        case reset
            set -Ue jars
        case list
            string collect -- $jars
        case _complete
            complete -c classpath -e
            complete -c classpath \
                -n "not __fish_seen_subcommand_from (classpath help | string replace \t '\t')" \
                -xa "(classpath help | string split -f1 \t)"
        case '*'
            echo 'Invalid subcommand'
            return 1
    end
end
