function nvm
    bash -c 'export NVM_DIR="$HOME/.nvm";
             [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh";
             nvm $@' _ $argv
end
