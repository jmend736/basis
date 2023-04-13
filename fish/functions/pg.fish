function pg
    argparse 'e/entry' 'c/clean' 'g' 'o/copts=' -- $argv

    if set -q _flag_clean
        rm -f *.class
        return
    end

    set -l entry (getor $_flag_entry Main)

    if not test -f "$entry.java"
        cp ~/.pg.Main.java "$entry.java"
    end

    setup-jars
    for javasrc in *.java
        javac --processor-path=~/.jars $_flag_g $_flag_copts $javasrc
        if test $status != 0
            return $status
        end
    end
    java $entry
end
