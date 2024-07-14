""
" Example: bss#tmpl#gradle#AddLib('foo', 'com/example/foo')
"
function! bss#tmpl#gradle#AddLib(name, package) abort
  if !filereadable('settings.gradle')
    throw bss#DumpAndThrow(
          \ 'ERROR(Failure): settings.gradle missing. Are you running in a gradle repo?')
  endif
  let package_path          = substitute(a:package, '\.', '/', 'g')
  let package_java          = substitute(a:package, '/', '.', 'g')
  let main_class            = 'Main'
  let files = {
        \   a:name: {
        \     $'src/main/java/{package_path}': {
        \       $'{main_class}.java': bss#tmpl#java#BasicMainContent(package_java, main_class),
        \     },
        \     $'src/test/java/{package_path}': {
        \       $'{main_test}.java': bss#tmpl#java#BasicMainTestContent(package_java, main_class),
        \     },
        \     'build.gradle': bss#tmpl#gradle#LibraryBuildGradleContent(),
        \   },
        \ }
  call bss#tmpl#Write(files)
  call writefile([$"include('{a:name}')"], 'settings.gradle', 'a')
endfunction

function! bss#tmpl#gradle#LibraryBuildGradleContent() abort
  let contents =<< eval trim END
    plugins {{
        // Apply the java-library plugin for API and implementation separation.
        id 'java-library'
    }}

    repositories {{
        // Use Maven Central for resolving dependencies.
        mavenCentral()
    }}

    dependencies {{
        // This dependency is used internally, and not exposed to consumers on their own compile classpath.
        implementation 'com.google.guava:guava:33.2.1-jre'
        testImplementation 'com.google.truth:truth:1.4.4'
    }}

    testing {{
        suites {{
            // Configure the built-in test suite
            test {{
                // Use JUnit4 test framework
                useJUnit('4.13.2')
            }}
        }}
    }}

    // Apply a specific Java toolchain to ease working on different environments.
    java {{
        toolchain {{
            languageVersion = JavaLanguageVersion.of(21)
        }}
    }}
  END
  return contents
endfunction
