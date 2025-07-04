function mkdirs
    switch $argv[1]
        case java
            argparse 'p/package=' -- $argv[2..]
            set -l package_flag (getor $_flag_package 'pg')
            set -l package (string replace --all '.' '/' $package_flag)
            mkdir -p {src,out}/{main,test}/java/$package
        case _complete
            set -l code (functions (status current-function) | string collect)
            string match --regex --all --quiet \
                '\s*case (?<all_subcommands>( *[^_](\w|\.)+)+)' \
                -- $code
            set -l subcommands (string split --no-empty ' ' $all_subcommands)
            complete -c (status current-function) \
                -n "not __fish_seen_subcommand_from $subcommands" \
                -xa "$subcommands"
            complete -c (status current-function) \
                -n "not __fish_seen_subcommand_from java" \
                -l package -s p \
                -x
    end
end
