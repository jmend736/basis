function re_verbose --description Strip\ regex\ of\ \#-comments\ and\ indentation.\ Like\ Python\'s\ re.VERBOSE.
    set -l indent__  '(?<indent>^\s*)'
    set -l re__      '(?<re>.*?)'
    set -l comment__ '(?<comment>(?:\s*#.*)?$)'
    string collect -- $argv |
        string replace --regex "$indent__($re__)$comment__" '$re' $line |
        string join --no-empty ''
end
