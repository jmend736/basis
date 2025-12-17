function gradle-init
    argparse 'g/gradle=' 'j/java=' 'p/package=' -- $argv
    set -l GRADLE_VERSION 9.1.0
    if set -q _flag_gradle
        set GRADLE_VERSION $_flag_gradle
    end
    set -l JAVA_VERSION 21
    if set -q _flag_java
        set JAVA_VERSION $_flag_java
    end
    set -l PACKAGE pg
    if set -q _flag_package
        set PACKAGE $_flag_package
    end

    set -l base_args \
        --overwrite \
        --no-incubating \
        --no-comments \
        --dsl groovy \
        --java-version $JAVA_VERSION \
        --package $PACKAGE \
        --project-name pg \
        --no-split-project \

    switch $argv[1]
        case kotlin
            gradle-init _wrapper
            ./gradlew init \
                $base_args \
                --test-framework kotlintest \
                --type kotlin-application
            gradle-init _make
        case java
            gradle-init _wrapper
            ./gradlew init \
                $base_args \
                --test-framework junit \
                --type java-application
            gradle-init _make
        case _wrapper
            gradle wrapper --gradle-version=$GRADLE_VERSION
        case _make
            begin
                echo -e ".PHONY: all"
                echo -e "all:"
                echo -e "\t./gradlew run"
            end > Makefile
        case _complete
            set -l code (functions (status current-function) | string collect)
            string match --regex --all --quiet \
                '\s*case (?<all_subcommands>( *[^_](\w|\.)+)+)' \
                -- $code
            set -l subcommands (string split --no-empty ' ' $all_subcommands)
            complete -c (status current-function) \
                -n "not __fish_seen_subcommand_from $subcommands" \
                -xa "$subcommands"

            complete -c (status current-function) \
                -d "Gradle version" \
                -s g -l gradle -xa "9.2.1"

            complete -c (status current-function) \
                -d "Java version" \
                -s j -l java -xa "21 25"

            complete -c (status current-function) \
                -d "Java pacakge" \
                -s p -l package -xa "pg io.jmend"
        case ''
            gradle-init java
        case '*'
            echo "Invalid command: $argv[1]"
    end
end
