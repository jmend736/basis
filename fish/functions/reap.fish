function reap
  if not set -q -U _sowed
    echo 'You must sow before reaping!' >&2
    return 1
  end
  string collect -- $_sowed
  set -e -U _sowed
end
