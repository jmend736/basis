function datediff
    argparse 'f/from=' 't/to=' 'q/query' -- $argv
    set -l from (date '-d'$_flag_from +%s)
    set -l to (date '-d'$_flag_to +%s)
    set -l diff (math $to - $from)
    if set -q _flag_query
        test "$diff" -gt 0
        return $status
    else
        echo $diff
    end
end
