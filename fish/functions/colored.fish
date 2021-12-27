function colored --argument cname --description 'Print colored text'
    echo -s (set_color $cname) "$argv[2..]" (set_color normal)
end
