function tomd
    set -l first yes
    for arg in $argv
        if test "$first" = "yes"
            set first "no"
        else
            echo
        end
        echo $arg
        string repeat -n 72 '='
        echo '```'
        cat $arg
        echo '```'
    end
end
