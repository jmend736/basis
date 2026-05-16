""
" Constructs an import cache from an import list:
"
"   import_list  = ['java.util.concurrent.Future']
"
"       becomes
"
"   import_cache = {'Future': ['java.util.concurrent.Future']}
"
function! bss#imp#BuildJvmImportCache(import_list) abort
  let cache = {}
  for import in a:import_list
    let name = slice(import, strridx(import, '.') + 1)
    if has_key(cache, name)
      call add(cache[name], import)
    else
      let cache[name] = [import]
    endif
  endfor
  return cache
endfunction

""
" Constructs an import cache from an import list:
"
"   import_dict  = {'<random>': ['random_device']}
"
"       becomes
"
"   import_cache = {'random_device': ['<random>']}
"
function! bss#imp#BuildCppImportCache(import_dict) abort
  let cache = {}
  for [import, entries] in items(a:import_dict)
    for entry in entries
      if has_key(cache, entry)
        call add(cache[entry], import)
      else
        let cache[entry] = [import]
      endif
    endfor
  endfor
  return cache
endfunction

""
" Attempt to find and add import from an import cache.
"
" If imports are found, {add_import_fname} is used to insert the new imports.
"
" Returns true if an import was found/added, else false.
"
function! bss#imp#TryAddImportFromCache(import_cache, entry, add_import_fname) abort
  let l:imports = get(a:import_cache, a:entry, [])
  if !empty(l:imports)
    call bss#imp#AddOrSelectImport(l:imports, a:add_import_fname)
    return v:true
  else
    return v:false
  endif
endfunction

function! bss#imp#AddOrSelectImport(options, add_import_fname) abort
  if len(a:options) == 1
    call call(a:add_import_fname, a:options)
  elseif len(a:options) > 1
    call maktaba#ui#selector#Create(a:options)
          \.WithMappings({'<cr>': [a:add_import_fname, 'Close', 'Add import']})
          \.Show()
  endif
endfunction

function! bss#imp#AddImportJava(import) abort
  call bss#imp#AddImportJvm('import ' .. a:import .. ';')
endfunction

function! bss#imp#AddImportKotlin(import) abort
  call bss#imp#AddImportJvm('import ' .. a:import)
endfunction

""
" Add an import for Java or Kotlin
"
" {import} is appended as-is, so for Java it must include a trailing
" semicolon.
"
function! bss#imp#AddImportJvm(import) abort
    let l:result = search(a:import .. '$', 'nw')
    if l:result == 0
      let l:start = search('^import', 'nw')
      if l:start == 0
        let l:start = search('^package', 'nw')
        call append(l:start, [""])
        let l:start += 1
      endif
      call append(l:start, [a:import])
      echom "Adding: " .. a:import
    else
      echom "Already Present: " .. a:import
    endif
endfunction

""
" Add an import for C++
"
" {import} is appended as `#include {import}`
"
function! bss#imp#AddImportCpp(import) abort
  let l:import = '#include ' .. a:import
  let l:result = search(l:import, 'nw')
  if l:result == 0
    let l:start = search('^#include', 'nw')
    call append(l:start, [l:import])
    echom "Adding: " .. a:import
  else
    echom "Already Present: " .. a:import
  endif
endfunction
