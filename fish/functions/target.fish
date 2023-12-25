function target
    bazel query 'same_pkg_direct_rdeps('$argv[1]')' 2>/dev/null | string match -re '//'
end
