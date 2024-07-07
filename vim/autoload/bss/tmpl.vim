""
" Given a map from filename to list of lines, write out any files that are not
" already present.
"
" Example Usage.
"   Write({'FileName': ['line1', 'line2', ...]})
"
function! bss#tmpl#Write(files) abort
  for [filename, contents] in a:files
    if !filereadable(filename)
      call writefile(filename, contents)
      echom $"Wrote {filename}."
    endif
  endfor
endfunction
