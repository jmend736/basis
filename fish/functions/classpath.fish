function classpath --description '$CLASSPATH management'
    set -l command $argv[1]
    set -l args $argv[2..]
    switch $command
        case help
            string collect -- \
                "setup	'[]: Set global \$CLASSPATH to \$jars'" \
                "add	'[{file}]: Add {file} to \$jars.'" \
                "add-gradle	'Select jar from .gradle to track in \$jars'" \
                "reset	'Clear \$jars'" \
                "list	'List tracked \$jars'" \
                "list-all-classes	'outputs classes all \$jars'" \
                "list-classes	'(1 arg) outputs classes in jar/jmod'" \
                "help	'Print this help'"
        case setup
            set -xg CLASSPATH $jars
        case reset
            set -U jars
        case find
            pushd $HOME/.gradle/
            realpath (fzf $args)
            popd
        case add
            set -Ua jars (realpath $args)
        case add-gradle
            classpath add (classpath find -m)
        case reset
            set -Ue jars
        case list
            string collect -- $jars
        case list-all-classes
            for jar in $jars
                classpath list-classes $jar
            end
        case list-classes
            if test -z "$args"
                set args $jars
            end
            jar tf $args \
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
            classpath list | ag '\.jar$' | string join ':'
    end
end
