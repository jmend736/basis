function complete_arg
    set -l helptext '
    complete_arg - Convert argparse pattern to complete arg

SYNOPSIS

    complete_arg <argstring>...

    complete_arg [--help]

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
    argparse h/help -- $argv

    if set -q _flag_help
        echo $helptext
        return
    end

    for fmt in $argv
        if set -l match (string match -r '([a-zA-Z0-9])([/-])([a-zA-Z0-9_-]*)(=|=\?|=\+)?' $fmt)
            # a/abc=
            test $match[3] = /; and echo '-s'$match[2]
            echo '-l'$match[4]
            switch $match[5]
                case '=' '=\+'
                    echo -r
            end
        else if set -l match (string match -r '([a-zA-Z0-9_-])(=|=\?|=\+)?' $fmt)
            # a=
            echo '-s'$match[2]
            switch $match[3]
                case '=' '=\+'
                    echo -r
            end
        else if set -l match (string match -r '([a-zA-Z0-9_-]+)(=|=\?|=\+)?' $fmt)
            # abc=
            echo '-l'$match[2]
            switch $match[3]
                case '=' '=\+'
                    echo -r
            end
        end
    end
    return
end
