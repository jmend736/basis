function remove-colors
    sed 's/\x1b\[[0-9;]*m//g'
end
