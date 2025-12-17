
if !exists('g:bss_java_fix') || !g:bss_markdown_fix
  finish
endif

syntax keyword javaClassDecl record sealed non\-sealed permits
syntax keyword javaStatement yield
