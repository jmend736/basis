function tmux-info
    argparse \
        --ignore-unknown \
        --exclusive clients,sessions,panes,windows \
        a/all \
        s/sessions \
        c/clients \
        w/windows \
        p/panes \
        sep= \
        -- $argv

    set -l all
    if set -q _flag_all
        set all '-a'
    end

    set -l sep ' '
    if set -q _flag_sep
        set sep $_flag_sep
    end

    set -l args (string join --no-empty $sep '#{'$argv'}')

    if set -q _flag_sessions
        tmux list-sessions -F$args
    else if set -q _flag_clients
        tmux list-clients -F$args
    else if set -q _flag_windows
        tmux list-windows $all -F$args
    else if set -q _flag_panes
        tmux list-panes $all -F$args
    else
        tmux display -p $args
    end
end
