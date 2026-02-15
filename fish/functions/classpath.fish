function classpath --description '$CLASSPATH management'
    switch $argv[1]
        case help
            string collect -- \
                "setup	'Set global \$CLASSPATH to \$jars'" \
                "add	'Select jar from .gradle to track in \$jars'" \
                "reset	'Clear \$jars'" \
                "list	'List tracked \$jars'" \
                "list-all-classes	'outputs classes all \$jars'" \
                "list-classes	'(1 arg) outputs classes in jar/jmod'" \
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
        case list-all-classes
            for jar in $jars
                classpath list-classes $jar
            end
        case list-classes
            jar tf $argv[2] \
                | string replace --regex --filter '^(classes/)?(.*)\.class' '$2' \
                | string match --invert --regex '\$' \
                | string match --invert --regex 'package-info' \
                | string replace --all '/' '.'
        case _complete
            complete -c classpath -e
            complete -c classpath \
                -n "not __fish_seen_subcommand_from (classpath help | string split -f1 \t)" \
                -xa "(classpath help | string replace \t "\\t")"

        case '*'
            echo 'Invalid subcommand'
            return 1
    end
end
