function mkrt --description 'Make a random temporary directory'
  set -l args \
    'j/java Make java-specific random temp' \
    'c/complete Setup completions for mkrt' \
    'h/help Show this help'

  argparse (string split -f1 ' ' $args) -- $argv

  if set -q _flag_help
    string collect -- $args
  else if set -q _flag_complete
    complete -c mkrt -f
    for arg in $args
      set -l arg_help (string split -m1 ' ' $arg)
      set -l parts (string split '/' $arg_help[1])
      complete -c mkrt -s$parts[1] -l$parts[2] -d"$arg_help[2]"
    end
  else if set -q _flag_java
    mkrt
    touch Main.java
    echo '.PHONY: build run
      all:
      	javac Main.java
      run:
      	java Main' | string trim -c' ' >> Makefile
  else
    pushd (mktemp -d /tmp/pg-XXXX)
  end

end
