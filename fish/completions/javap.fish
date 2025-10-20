complete -c javap \
    -e

complete -c javap \
    -l help -o help \
    -d 'Print this usage message' \
    -f

complete -c javap \
    -o version \
    -d 'Version information' \
    -f

complete -c javap \
    -o verbose -s v \
    -d 'Print additional information' \
    -f

complete -c javap \
    -s l \
    -d 'Print line number and local variable tables' \
    -f

complete -c javap \
    -o public \
    -d 'Show only public classes and members' \
    -f

complete -c javap \
    -o protected \
    -d 'Show protected/public classes and members' \
    -f

complete -c javap \
    -o package \
    -d 'Show package/protected/public classes' \
    -f

complete -c javap \
    -o private -s p \
    -d 'Show all classes and members' \
    -f

complete -c javap \
    -s c \
    -d 'Disassemble the code' \
    -f
complete -c javap \
    -s s \
    -d 'Print internal type signatures' \
    -f

complete -c javap \
    -o sysinfo \
    -d 'Show system info (path, size, date, MD5 hash)' \
    -f

complete -c javap \
    -o constants \
    -d 'Show final constants' \
    -f

complete -c javap \
    -o classpath -o cp \
    -d 'Specify where to find user class files' \
    -rF

complete -c javap \
    -n 'not string match -rq "(-cp|-classpath)" (commandline)' \
    -a '(_javap_classes)'

complete -c javap \
    -n 'string match -rq "(-cp|-classpath)" (commandline)' \
    -xa '(_javap_cp)'

function _javap_classes
    set -l base (dirname (dirname (realpath (which java))))
    cat $base/lib/classlist \
        | string match -ve '@' \
        | string match -ve '#' \
        | string replace -ra '(\/|\$)' '.'
end

function _javap_cp
    set -l next_cp
    set -l cp_opt
    for arg in (commandline -o)
        if test -n "$next_cp"
            set cp_opt $arg
            break
        end
        switch $arg
            case -cp -classpath
                set next_cp 1
        end
    end
    if test -n "$cp_opt"
        jar tf $cp_opt \
            | string replace -rf '\.class$' '' \
            | string replace -ra '(\/|\$)' '.'
    end
end
