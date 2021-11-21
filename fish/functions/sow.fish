function sow
  set -l helptext '
    sow - Store a value, to be reaped later

SYNOPSIS
    COMMAND | sow [OPTIONS]
    sow [OPTIONS] VALUES...

EXAMPLES
    $ sow value
    $ reap
    value

    $ echo value | sow
    $ reap
    value

DESCRIPTION
    Store the passed in VALUE or read from stdin if no value arguments are
    given. Can be accessed with reap from any fish instance.

OPTIONS

    *   ( -a | --append ) do not overwrite current value, append instead
'
  argparse -s 'a/append' 'h/help' -- $argv

  if set -q _flag_help
    echo $helptext
    return
  end

  set -l args $argv
  if test -z "$args"
    while read line
      set -a args $line
    end
  end
  set $_flag_append -U _sowed $args
end
