function tmux-info --argument name
    tmux display -p "#{$name}"
end
