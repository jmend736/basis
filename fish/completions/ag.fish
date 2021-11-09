# Modes
complete -c ag -x \
   -s g \
   -d 'Print filenames matching PATTERN'

complete -c ag -x \
   -l files-with-matches -s l \
   -d 'Print filenames with matches'

complete -c ag -x \
   -l files-without-matches -s L \
   -d 'Print filenames without matches'

complete -c ag -x \
   -l invert-match -s v \
   -d 'Invert match'

# Configuring Output
complete -c ag -x \
   -l only-matching -s o \
   -d 'Only print match'

complete -c ag -f \
   -l filename -l nofilename \
   -d 'Print file names with matches'

complete -c ag -f \
   -l break -l nobreak \
   -d 'Print a newline between matches in different files'

# Configuring Search
complete -c ag -x \
   -l file-search-regex -s G \
   -d 'Only search files whose names match PATTERN'

complete -c ag -x \
   -l ignore \
   -d 'Ignore files/directories whose names match this PATTERN'

complete -c ag -x \
   -l ignore-dir \
   -d 'Ignore directories whose names match this NAME'

complete -c ag -f \
   -l all-types -s a \
   -d 'Search all files, incl. hidden ones'
