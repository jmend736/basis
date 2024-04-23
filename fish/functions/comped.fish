function comped --wraps=functions --argument fname
    vim "~/.config/fish/completions/$fname.fish"
    complete -c $fname -e
end
