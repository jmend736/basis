function comped --wraps=functions --argument fname
    if test -z "$fname"
        return 1
    end
    vim ~/.config/fish/completions/$fname.fish
end
