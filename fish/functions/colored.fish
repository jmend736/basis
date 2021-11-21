function colored --argument cname
  echo -s (set_color $cname) $argv[2..-1] (set_color normal)
end
