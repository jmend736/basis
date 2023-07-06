function mkrt --description 'Make a random temporary directory'
    argparse 'p/py' 'c/cc' -- $argv

    if set -q _flag_py
        set -l dir (mktemp -d ~/pg-py/XXXX)
        pushd $dir
        echo $dir >> ~/pg-py/entries
        return
    end
    if set -q _flag_cc
        set -l dir (~/pg-cc/make-pg-cc.fish)
        pushd $dir
        return
    end
    pushd (mktemp -d /tmp/pg-XXXX)
end
