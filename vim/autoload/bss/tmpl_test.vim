const s:Write = {desc -> bss#tmpl#Write(desc, v:true)}
function! s:Test(name) abort
  echom repeat('-', 72)
  echom a:name
  echom repeat('-', 72)
endfunction

call s:Test('writeJustFile -> writesFile')
call s:Write({'hello': ['hello', 'world']})

call s:Test('writeBothDirAndFiles -> makeDirThenFiles')
call s:Write({'a/b/c': {'hello': ['hello', 'world']}})

call s:Test('multipleFiles -> writesAll')
call s:Write({
      \   'main/src/java/com/example': {
      \     'foo': ['hello', 'world'],
      \     'bar': ['hello', 'world'],
      \   }
      \ })

call s:Test('invalidFile -> throwsWrongType')
try
  call s:Write({
        \   'main/src/java/com/example': {
        \     'foo': 32333,
        \     'bar': ['hello', 'world'],
        \   }
        \ })
catch /ERROR/
  echom "Expect number instead of list error:"
  call bss#DumpCurrentException()
endtry

call s:Test('Test 4')
let name    = 'pg'
let package = 'io/jmend/pg'
let jpkg    = substitute(package, '/', '.', 'g')
call s:Write({
      \   $"{name}/src/main/java/{package}": {
      \     'Main.java': [
      \       $"package {jpkg}",
      \     ]
      \   },
      \   $"{name}/src/test/java/{package}": {}
      \ })
