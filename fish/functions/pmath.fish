function pmath

    set -f op $argv[1]
    set -f args $argv[2..]

    test (count $args) -gt 0
    or read -f -z -a args

    switch $op
        case infix + - "\*" 'x' / ^ %
            math (string join $op $args)
        case prefix-unary abs acos asin atan ceil cos cosh exp fac floor ln \
             log log10 log2 round sin sinh sqrt tan tanh
            for arg in $args
                math "$op($arg)"
            end
        case prefix-binary atan2 bitand bitor bitxor ncr npr pow
            if test (count $args) -ne 2
                echo "Invalid number of args! $op requires 2!"
                return 1
            end
            math $op (string join ',' $args)
        case prefix-nary max min
            if test -z "$args"
                echo "Invalid number of args! $op at least 1!"
                return 1
            end
            math $op (string join ',' $args)
    end
end
