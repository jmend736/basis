function sow
  set -l args $argv
  if test -z "$args"
    while read line
      set -a args $line
    end
  end
  set -U _sowed $args
end
