function jdwp --argument port
    set -l port (if test -n "$port"; echo $port; else; echo 9090; end)
    echo "-agentlib:jdwp=transport=dt_socket,server=y,address=localhost:$port"
end
