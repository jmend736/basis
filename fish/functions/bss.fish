# Defined in /home/jmend/.config/fish/functions/bss.fish @ line 1
function bss
    argparse -i 'h/help' 's/spaces' -- $argv
    set -l spaces 8
    if set -q _flag_spaces
        set spaces $_flag_spaces
    end

    set -l pattern '^\s{'$spaces'}case (\w+) -h"(.*)"'

    switch $argv[1]
        case help -h"Get helptext"
            functions $argv[2] | string replace -rf \
                $pattern '$1\n\t$2'
        case complete -h"Setup completions"
            string collect -- (functions $argv[2] | \
                    string replace -rf $pattern '$1\t$2')
            complete -c $argv[2] \
                -xa \
                (string collect -- (functions $argv[2] | \
                  string replace -rf $pattern '$1\t$2'))
    end
end
