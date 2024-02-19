""
" Some modifications to the default markdown syntax highlighting
"
" -   Disable indented code blocks
"

if !exists('g:bss_markdown_fix') || !g:bss_markdown_fix
  finish
endif

syntax clear markdownCodeBlock
syntax region markdownCodeBlock matchgroup=markdownCodeDelimiter start="^\s*\z(`\{3,\}\).*$" end="^\s*\z1\ze\s*$" keepend
syntax region markdownCodeBlock matchgroup=markdownCodeDelimiter start="^\s*\z(\~\{3,\}\).*$" end="^\s*\z1\ze\s*$" keepend

if exists('g:gruvbox_bold')
  highlight link markdownH1 GruvboxRedBold
  highlight link markdownH2 GruvboxBlueBold
  highlight link markdownH3 GruvboxGreenBold
  highlight link markdownH4 GruvboxPurpleBold

  highlight link markdownBold GruvboxFg4
  highlight link markdownBoldDelimiter GruvboxFg4
  highlight link markdownItalic GruvboxFg2
  highlight link markdownItalicDelimiter GruvboxFg2
endif
