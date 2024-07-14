""
" Given a map from filename to list of lines, write out any files that are not
" already present.
"
" Example Usage.
"   Write({'FileName': ['line1', 'line2', ...]})
"
function! bss#tmpl#Write(files, dryrun=v:false) abort
  let writer = s:Writer(a:dryrun)
  call s:Write(a:files, writer)
endfunction

function! s:Write(files, writer, context='') abort
  for [filename, contents] in items(a:files)
    let path = maktaba#path#Join([a:context, filename])
    if type(contents) is v:t_dict
      call a:writer.mkdir(filename)
      call s:Write(contents, a:writer, path)
    elseif type(contents) is v:t_list
      call a:writer.write(contents, path)
    else
      throw $'ERROR(InvalidArguments): {{contents}} must be a string or dict, instead got {string(contents)}'
    endif
  endfor
endfunction

let s:WriterProto = {
      \   'dryrun': v:false,
      \   'context': '',
      \ }

function! s:Writer(dryrun) abort
  return deepcopy(s:WriterProto)->extend({
        \   'dryrun'  : a:dryrun,
        \   'context' : '',
        \ })
endfunction

""
" Execute {Runnable} or emit {desc}; based on dryrun state.
"
" {desc}     : string description of action of {Runnable}.
" {Runnable} : no-arg callable that only runs when {self.dryrun} is false.
"
function! s:WriterProto.run(desc, Runnable) abort
  if self.dryrun
    echom a:desc
  else
    call a:Runnable()
  endif
endfunction

""
" Writes {contents} to {file}.
"
" {contents} : A list of lines; each line is a string.
"            : Also, see {object} for |writefile|.
" {file}     : path to file to write
"
function! s:WriterProto.write(contents, file) abort
  call maktaba#ensure#IsList(a:contents)
  call maktaba#ensure#IsString(a:file)
  if !filereadable(a:file)
    call self.run(
          \   $"write {a:file} ({len(a:contents)} lines)",
          \   { -> writefile(a:contents, a:file)}
          \ )
  endif
endfunction

function! s:WriterProto.mkdir(path) abort
  call maktaba#ensure#IsString(a:path)
  if !isdirectory(a:path)
    call self.run(
          \   $"mkdir {a:path}",
          \   { -> mkdir(a:path, 'p')}
          \ )
  endif
endfunction
