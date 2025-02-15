function mkrt --description 'Make a random temporary directory'
    switch $argv[1]
        case make
            set -l dir (mktemp -d /tmp/pg-XXXX)
            ln -s -f $dir /tmp/pg-latest
            pushd $dir
        case gradle
            mkrt make
            gradle wrapper --gradle-version=8.8 $argv[2..]
            ./gradlew init \
                --type java-application \
                --dsl groovy \
                --package pg \
                --project-name pg \
                --test-framework junit-jupiter
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
