function gradle-init
    argparse 'g/gradle=' 'j/java=' 'p/package=' 'd/dsl=' -- $argv

    set -l GRADLE_VERSIONS 9.1.0
    set -l GRADLE_VERSION $GRADLE_VERSIONS[1]
    if set -q _flag_gradle
        set GRADLE_VERSION $_flag_gradle
    end

    set -l JAVA_VERSIONS 21 25 17
    set -l JAVA_VERSION $JAVA_VERSIONS[1]
    if set -q _flag_java
        set JAVA_VERSION $_flag_java
    end

    set -l PACKAGES pg io.jmend
    set -l PACKAGE $PACKAGES[1]
    if set -q _flag_package
        set PACKAGE $_flag_package
    end

    set -l DSLS kotlin groovy
    set -l DSL $DSLS[1]
    if set -q _flag_dsl
        set DSL $_flag_dsl
    end

    switch $argv[1]
        case kotlin java
            gradle-init _wrapper
            ./gradlew init (gradle-init args $argv[1])
            gradle-init _make
        case args
            set -l base_args \
                --overwrite \
                --no-incubating \
                --no-comments \
                --dsl $DSL \
                --java-version $JAVA_VERSION \
                --package $PACKAGE \
                --project-name $PACKAGE \
                --no-split-project
            switch $argv[2]
                case java
                    string collect -- $base_args \
                        --test-framework junit \
                        --type java-application
                case kotlin ''
                    string collect -- $base_args \
                        --test-framework kotlintest \
                        --type kotlin-application
                case '*'
                    echo "Invalid type"
            end
        case _wrapper
            gradle wrapper --gradle-version=$GRADLE_VERSION
        case _make
            begin
                echo -e ".PHONY: all"
                echo -e "all: run"
                echo -e ""
                echo -e "run:"
                echo -e "\t./gradlew run"
                echo -e ""
                echo -e "test:"
                echo -e "\t./gradlew --rerun-tasks test"
                echo -e ""
            end > Makefile
        case _complete
            set -l code (functions (status current-function) | string collect)
            string match --regex --all --quiet \
                '\s{8}case (?<all_subcommands>( *[^_](\w|\.)+)+)' \
                -- $code
            set -l subcommands (string split --no-empty ' ' $all_subcommands)
            complete -c (status current-function) \
                -n "not __fish_seen_subcommand_from $subcommands" \
                -xa "$subcommands"

            complete -c (status current-function) \
                -d "Gradle version" \
                -s g -l gradle -xa "$GRADLE_VERSIONS"

            complete -c (status current-function) \
                -d "Java version" \
                -s j -l java -xa "$JAVA_VERSIONS"

            complete -c (status current-function) \
                -d "Gradle DSL" \
                -s d -l dsl -xa "$DSLS"

            complete -c (status current-function) \
                -d "Java pacakge" \
                -s p -l package -xa "$PACKAGES"
        case '*'
            echo "Invalid command: $argv[1]"
    end
end
