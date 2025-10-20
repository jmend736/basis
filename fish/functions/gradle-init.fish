function gradle-init
    gradle wrapper --gradle-version=9.1.0
    ./gradlew init \
        --overwrite \
        --no-incubating \
        --no-comments \
        --dsl kotlin \
        --java-version 21 \
        --package pg \
        --project-name pg \
        --no-split-project \
        --test-framework kotlintest \
        --type kotlin-application
    begin
        echo -e ".PHONY: all"
        echo -e "all:"
        echo -e "\t./gradlew run"
    end > Makefile
end
