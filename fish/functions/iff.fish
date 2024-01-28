function iff --no-scope-shadowing --argument flag_name if_true if_false
    if set -q _flag_$flag_name
        echo $if_true
    else
        echo $if_false
    end
end
