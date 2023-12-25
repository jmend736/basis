function argparse_complete
    set -l helptext '
    argparse_complete - Complete using argparse format strings

SYNOPSIS

    argparse_complete -c <command> <argstring>...

    argparse_complete [--help]

DESCRIPTION

    There are two usage pattersns for this function:

    Inline:
    ```
    argparse (argparse_complete -c func \
        "a/arg1 {help-text-1}" \
        "b/arg2 {help-text-2}" \
        "h/help {help-text-3}" \
        -- $argv)
    or return
    ```

    Separately:
    ```
    argparse_complete -c func \
        "a/arg1 {help-text-1}" \
        "b/arg2 {help-text-2}" \
        "h/help {help-text-3}" \
        --complete
    ```

ARGSTRING

    The <argstring> can be one matching these:

      b/
      b/both
      b/both=
      b/both=?
      b/both=+
      justlong
      justlong=
      justlong=?
      justlong=+

    After the argparse format specifier, the <argstring> can contain addition
    arguments that are passed directly to the complete command. For example:

    b/both -d"help text goes here"
'

    # argparse_complete Flag Handling
    # ==================================================================
    argparse --stop-nonopt h/help c/command= -- $argv

    set -l complete
    if string match -rq '(--complete)' $argv
        set complete yes
    end

    if not set -q _flag_command
        echo 'Missing -c/--command argument!'
        return 1
    end

    if set -q _flag_help
        echo $helptext
        return
    end

    # `argparse` DSL Patterns
    # ==================================================================
    set -l short__ '(?<short>[a-zA-Z])'
    set -l div__   '(?<div>(?<no_short>-)|/)'
    set -l long__  '(?<long>[a-zA-Z_-]+)'
    set -l qual__  '(?<qual>=\?|=\+|=)'
    set -l addl__  '(?:(?:\s*)(?<addl>.*$))'

    # `complete` Argument Construction
    # ==================================================================
    set -l tail
    for fmt in $argv

        # complete Argument Construction
        # ==============================================================

        if test -n "$tail"
            echo $fmt
            continue
        else if test "$fmt" = "--"
             and not test -n "$complete"
            set tail yes
            echo -s - -
            continue
        else if test "$fmt" = "--"
            break
        end

        # complete Argument Construction
        # ==============================================================

        string match -rq "($short__$div__)?$long__$qual__?$addl__?" -- $fmt
        or string match -rq "$short__$qual__?$addl__?" -- $fmt

        set -l args

        if test -n "$short"
           and not test -n "$no_short"
            set -a args "--short-option" $short
        end

        if test -n "$long"
            set -a args "--long-option" $long
        end

        if test "$qual" = "="
           or test "$qual" = "=+"
            set -a args "--require-parameter"
        end

        if test -n "$addl"
            set -a args (eval "string collect -- $addl")
        end

        # Format Argument Handling
        # ==============================================================
        if test -n "$complete"
            # Define Completions
            # ----------------------------------------------------------
            complete -c $_flag_command $args
            echo -s - -
        else
            # Forward Argument
            # ----------------------------------------------------------
            if test -n "$short"
                echo "$short$div$long$qual"
            else
                echo "$long$qual"
            end
        end

    end
    if test -n "$complete"
        return 1
    else
        return
    end
end
