function re_verbose --description Strip\ regex\ of\ \#-comments\ and\ indentation.\ Like\ Python\'s\ re.VERBOSE.
    set -l re__      '(?<re>.*?)'
    set -l comment__ '(?<comment>(?:\s*#.*$)?)'
    set -l indent__  '(?<indent>^\s*)'
    string collect -- $argv |
        string replace --regex "$indent__($re__)$comment__" '$re' $line |
        string join --no-empty ''
end
