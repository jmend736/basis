# Defined via `source`
function bd
    argparse -i 'q/quiet' -- $argv

    set -l package $argv[1]
    set -l command $argv[2]
    set -l args $argv[3..]

    set -l flags
    if set -q _flag_quiet
        set -a flags '-quiet'
    end

    buildozer $flags "$command $args" $package
end
