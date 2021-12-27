# Defined via `source`
function argparse_complete
    set -l helptext '
    argparse_complete - Complete using argparse format strings

SYNOPSIS

    argparse_complete -c <command> <argstring>...

    argparse_complete [--help]

DESCRIPTION

    This function converts <argstring> (arguments with the format expected by
    argparse) to arguments for the complete command. This allows you to write
    something like this:

      $ foo --help
      h/help Print this help
      a/all Another command

      $ complete -c foo (complete_arg (foo --help))

      $ complete -C 'foo '
      -h --help -a --all

ARGSTRING

    The <argstring> is largely defined as allowing for the format 
 input is currently limited to one of the forms:

      b/
      b/both
      b/both=
      b/both=?
      b/both=+
      justlong
      justlong=
      justlong=?
      justlong=+
'
    argparse h/help c/command= -- $argv

    if not set -q _flag_command
        echo 'Missing -c/--command argument!'
        return 1
    end

    if set -q _flag_help
        echo $helptext
        return
    end

    for fmt in $argv
        set -l args
        if set -l match (string match -r '([a-zA-Z0-9])([/-])([a-zA-Z0-9_-]*)(=|=\?|=\+)?' $fmt)
            # a/abc=
            test $match[3] = / && set -a args '-s'$match[2]
            set -a args '-l'$match[4]
            switch $match[5]
                case '=' '=\+'
                    set -a args '-r'
            end
        else if set -l match (string match -r '([a-zA-Z0-9_-])(=|=\?|=\+)?' $fmt)
            # a=
            set -a args '-s'$match[2]
            switch $match[3]
                case '=' '=\+'
                    set -a args '-r'
            end
        else if set -l match (string match -r '([a-zA-Z0-9_-]+)(=|=\?|=\+)?' $fmt)
            # abc=
            set -a args '-l'$match[2]
            switch $match[3]
                case '=' '=\+'
                    set -a args '-r'
            end
        end
        complete -c $_flag_command $args
    end
    return
end
