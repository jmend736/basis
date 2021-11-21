function reap
  set -l helptext '
    reap - Consume a sowed value

SYNOPSIS
    reap ( -q | --query )
    reap ( -p | --peek )

EXAMPLES
    $ sow value
    $ reap
    value

    $ echo value | sow
    $ reap
    value

DESCRIPTION
    Consume the last value that was passed to sow. This is built on top of
    UNIVERSAL variables allowing sow/reap to work between running fish
    instances. If a list of multiple items was stowed, then each item is
    printed on a different line.

    *   ( -q | --query ) no output is produced, instead the return status will
        be 0 if a value is available or 1 if no value is available.

    *   ( -p | --peek ) read the current value(s) without consuming it.
'
  argparse 'q/query' 'p/peek' 'h/help' -- $argv

  if set -q _flag_help
    echo $helptext
    return
  end

  if set -q _flag_query
    set -q -U _sowed
    return $status
  end

  if not set -q -U _sowed
    echo 'You must sow before reaping!' >&2
    return 1
  end
  string collect -- $_sowed
  if not set -q _flag_peek
    set -e -U _sowed
  end
end
