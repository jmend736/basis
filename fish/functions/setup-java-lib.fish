function setup-java-lib
    set -gx CLASSPATH $JAVA_LIB .
    set -gx JAVACOPTS \
        -processor org.openjdk.jmh.generators.BenchmarkProcessor,dagger.internal.codegen.ComponentProcessor \
        -implicit:none

    if test -d out/main/java
        set -a CLASSPATH out/main/java
    end

    if not test -f .ycm_extra_conf.py
        begin
            echo 'def Settings(**kwargs):'
            echo '  if kwargs["language"] == "java":'
            set -l cp_options (string join ', ' -- "'"$CLASSPATH"'")
            echo "    return {'ls': {'java.project.referencedLibraries': [$cp_options]}}"
        end >> .ycm_extra_conf.py
    end

end
