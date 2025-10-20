function setup-java-lib
    echo '>>> Creating CLASSPATH and JAVACOPTS'
    set -gx CLASSPATH $JAVA_LIB .
    set -gx JAVACOPTS \
        -processor org.openjdk.jmh.generators.BenchmarkProcessor,dagger.internal.codegen.ComponentProcessor \
        -implicit:none

    if test -d out/main/java
        echo '>>> Found out/main/java'
        set -a CLASSPATH out/main/java
        set -a JAVACOPTS \
            -d out/main/java \
            -s out/main/java
    end

    if not test -f .ycm_extra_conf.py
        echo '>>> Creating .ycm_extra_conf.py (hint :YcmRestartServer)'
        begin
            set -l cp_options (string join ', ' -- "'"$CLASSPATH"'")

            echo 'def Settings(**kwargs):'
            echo '  if kwargs["language"] == "java":'
            echo "    return {'ls': {'java.project.referencedLibraries': [$cp_options]}}"
        end >> .ycm_extra_conf.py
    end
end
