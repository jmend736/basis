function mkrt --description 'Make a random temporary directory'
    switch $argv[1]
        case help --help -h
            echo 'make   : Create an empty temporary directly'
            echo 'gradle : Create a new gradle project'
        case make m --make -m
            set -l dir (mktemp -d /tmp/pg-XXXX)
            ln -s -f $dir /tmp/pg-latest
            pushd $dir
        case gradle g -g --gradle
            mkrt make
            gradle wrapper --gradle-version=8.8 $argv[2..]
            # To get details of options:
            #   $ ./gradlew help --task init
            ./gradlew init \
                --type java-application \
                --java-version 21 \
                --no-split-project \
                --dsl groovy \
                --package pg \
                --project-name pg \
                --test-framework junit-jupiter \
                --no-incubating
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
