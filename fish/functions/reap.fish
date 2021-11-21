function reap
  argparse 'q' -- $argv
  if not set -q -U _sowed
    echo 'You must sow before reaping!' >&2
    return 1
  end
  string collect -- $_sowed
  if not set -q _flag_q
    set -e -U _sowed
  end
end
