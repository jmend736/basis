function sa
    if set -q SSH_AGENT_PID
        echo "Already running with pid $SSH_AGENT_PID"
        return
    end
    eval (ssh-agent -c)
    ssh-add $SSH_KEY
    function _sa_exit_handler --on-event fish_exit
        ssh-agent -k 2>&1
    end
end
