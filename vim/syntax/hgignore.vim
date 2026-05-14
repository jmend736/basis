if exists('b:current_syntax')
    finish
endif

syntax case match

syntax match hgignoreComment /\v#.*$/

syntax match hgignoreEscape /\\./

syntax keyword hgignoreSyntax contained syntax
syntax keyword hgignoreSyntaxKind contained regexp glob rootglob
syntax match hgignoreSyntaxExpr contains=hgignoreSyntax,hgignoreSyntaxKind,hgignoreComment /^syntax:.*/

highlight link hgignoreSyntax Statement
highlight link hgignoreSyntaxKind Type
highlight link hgignoreComment Comment
highlight link hgignoreEscape Special

let b:current_syntax = 'hgignore'
