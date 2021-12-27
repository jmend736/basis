function mkrt --description 'Make a random temporary directory'
    pushd (mktemp -d /tmp/pg-XXXX)
end
