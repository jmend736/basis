function iff --no-scope-shadowing
    set -l helptext '
    iff - Conditionally echo a value based on a flag

SYNOPSIS
    iff ( -e | --eval ) [flagname] [if_true] [if_false]

EXAMPLES
    $ argparse q/query -- --query
    $ set query (iff query yes no)
    $ echo $query
    yes

    $ argparse q/query -- --query
    $ set query (iff --eval query "echo 32" "true")
    $ echo $query
    32

DESCRIPTION
    Check if a flag of the given name is set. [flagname] may be provided with
    or without the leading `_flag_`. If the flag is set, then echo the
    [if_true] argument, otherwise, echo the [if_false] argument.

    *   ( -e | --eval ) evaluate the [if_true] and [if_false] arguments as fish
        commands.
'
    argparse -s h/help e/eval -- $argv
    set -l flag_name $argv[1]
    set -l if_true $argv[2]
    set -l if_false $argv[3]

    if set -q _flag_help
        echo $helptext
        return
    end

    set -l cmd echo
    if set -q _flag_eval
        set cmd eval
    end

    if not string match -q '_flag_*' "$flag_name"
        set flag_name "_flag_$flag_name"
    end

    if set -q $flag_name
        $cmd $if_true
    else
        $cmd $if_false
    end
end
