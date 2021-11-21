function sow
  set -l args $argv
  if test -z "$args"
    read args
  end
  set -U _sowed $args
end
