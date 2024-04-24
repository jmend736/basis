function printff
    set -l type (getor $argv[1] "s")
    set -l values $argv[2..]

    if test -z "$values"
        echo "%$type"
    else
        set -l width (math 1 + max (string length $values | string join ','))
        echo "%$width$type"
    end
end
