# Defined via `source`
function colored --argument cname
    echo -s (set_color $cname) "$argv[2..]" (set_color normal)
end
