function! bss#wtf#Initialize(add_defaults = v:true) abort
  let l:wtf = bss#wtf#Dict()
  if a:add_defaults
    call extend(l:wtf, s:wtf_defaults)
  endif
  command! -nargs=1 -complete=customlist,bss#wtf#Complete Wtf call bss#wtf#Print(<q-args>)
  return l:wtf
endfunction

" A map from a string key to a list of strings (each being a line)
function! bss#wtf#Dict() abort
  if !exists('g:BssWtf')
    let g:BssWtf = {}
  endif
  return g:BssWtf
endfunction

function! bss#wtf#Print(name) abort
  let l:wtf = bss#wtf#Dict()
  if !has_key(l:wtf, a:name)
    echoerr 'Invalid key: ' .. a:name
  endif
  echo join(l:wtf[a:name], "\n")
endfunction

function! bss#wtf#Complete(arg, cmdline, curpos) abort
  return keys(bss#wtf#Dict())
        \->filter({k, v -> !stridx(v, a:arg)})
endfunction

""
" Add entries for each name to lines
"
"     bss#wtf#Add('name', ['hello', 'world'])
"
" would add
"
"     :Wtf name
"     hello
"     world
"
" {names} can be a list of names for alternatives
"
"     bss#wtf#Add(['name', 'n'], ['hello', 'world'])
"
"     :Wtf name
"     hello
"     world
"
"     :Wtf n
"     hello
"     world
"
function! bss#wtf#Add(names, lines) abort
  let l:names = s:CoalesceListOfStrings('names', a:names)
  let l:lines = s:CoalesceListOfStrings('lines', a:lines)
  let l:dict = {}
  for l:name in l:names
    let l:dict[l:name] = l:lines
  endfor
  call bss#wtf#Extend(l:dict)
endfunction

""
" Adds the dictionary as a single addition, with each entry being printed on a
" newline with a `~` appearing between the key and value:
"
"     bss#wtf#AddDict('example', {'hello': 'world', 'something': 'else'})
"
"     :Wtf example
"     example:
"       hello     ~ world
"       something ~ else
"
function! bss#wtf#AddDict(names, dict) abort
  let l:wtf = bss#wtf#Dict()
  let l:names = s:CoalesceListOfStrings('names', a:names)
  let l:lines = s:DocMap(l:names[0], a:dict)
  call bss#wtf#Add(a:names, l:lines)
endfunction

function! bss#wtf#Extend(dict) abort
  let l:wtf = bss#wtf#Dict()
  call extend(l:wtf, a:dict)
endfunction

function! s:CoalesceListOfStrings(name, arg) abort
  if type(a:arg) is v:t_string
    return [a:arg]
  elseif type(a:arg) is v:t_list && !empty(a:arg) && type(a:arg[0]) is v:t_string
    return a:arg
  endif
  throw printf('ERROR(InvalidArguments): %s must be a string or non-empty list of strings!', a:name)
endfunction

function! s:DocMap(name, dict) abort
  let l:length = keys(a:dict)
        \->map({_, cmd -> strlen(cmd)})
        \->max()
  let l:lines = [a:name .. ':']
  for [cmd, desc] in sort(items(a:dict))
    eval l:lines->add(printf('  %-' .. l:length .. 's ~ %s', cmd, desc))
  endfor
  return l:lines
endfunction

let s:wtf_defaults = {}

let s:wtf_defaults.misc =<< END
Misc:
  :center     ~ Center visual selection!
  :redraw     ~ Useful for :echo-ish commands
  :exec|:echo ~ Both join args with spaces
  [i          ~ Display first line with <cword> (incl 'path')
  [I          ~ Display all line with <cword> (incl 'path')
  [<C-i>      ~ Jump to first line with <cword> (incl 'path')
  <C-w><C-i>  ~ New window and jump to first line with <cword> (incl 'path')
  gv          ~ Select last visual selection
  :Tab fmt    ~ Field delimiter is treated also a field!
  [N]wincmd w ~ Increment current winnr or jump to window [N]
  D C Y       ~ Delete to EOL...
  i_<C-(t|d)> ~ Increase/decrease indent of current line
  :exusage    ~ List ex commands
  :h:t{:r:e}  ~ expand() stuff
  %           ~ Use when ex cmd accepts path/file
  '[ ']       ~ last changed or yanked area
  '>          ~ last visual area
  'conceallevel'
              ~ Control syntax-defined character concealment
  <Bar>       ~ Used for :map
END
let s:wtf_defaults.redir =<< END
Redir:
  :redir      ~ Redirect messages to various places:
    END       ~ Stop redirecting
    > {file}  ~ Write to file
    >> {file} ~ Append to file
    @[a-z]    ~ Registers
    @[a-z]>
    @[a-z]>>
    @*>       ~ Clipboard
    => {var}  ~ Write {var}
    =>> {var} ~ Append to {var}

  :filter /{pat}/ {command}

  let {name} =<< EOF
  ...
  EOF

  :append
  ...
  .

  :insert
  ...
  .
END
let s:wtf_defaults.args =<< END
Args:
  line()      ~ Accepts . $ 'x
    col()
    getline()
    getpos()
    indent()
    virtcol()
  bufname()   ~ Accepts '' % #
    {get,append,delete}bufline()
    {get,set}bufvar()
    bufnr()
    bufwinid()
    getbufinfo()
END
let s:wtf_defaults.funcs =<< END
Function Names:
  normal: Foo
  script: <SNR>139_Foo
  lambda: {'<lambda>42'}
  numbered: {'42'}

  NOTE: function() resolves s: when creating the Funcref
END
let s:wtf_defaults.prev =<< END
Previous Actions:
  gv    ~ select prev. selection
  '[ '] ~ prev. changed or yanked yext
  '< '> ~ prev. selected visual area
  '.    ~ Last change start
  ]' [' ~ Move to next/prev mark
END
let s:wtf_defaults.motions =<< END
Motions:
  inclusive:
    $ g_ f t e E %
  exclusive:
    ...
Semantics:
  aw ~ Around word, including leading xor trailing whitespace
  iw ~ Inner word
END
let s:wtf_defaults.folds =<< END
Folds:
  Folds can become desynced from foldlevel.
  motions:
    z[jk]  -- Jump to start/end of next/prev fold
    [[]]z  -- Jump to end-points of current fold
  folds:
    z[fd]  -- create/delete fold
    z[oca] -- open/close/alternate one fold
    z[OCA] -- open/close/alternate folds recursively
  foldlevels:
    z[rm]  -- add/sub one to/from foldlevel
    z[RM]  -- max/min foldlevel
    z[xX]  -- apply foldlevel (if zx also call zv)
  fold creation:
    zD     -- Deletes folds recursively
    zE     -- Deletes all folds
  misc:
    zv     -- open folds enough to view cursor
    z[nNi] -- Disable/enable/toggle folding
END
let s:wtf_defaults.tabs =<< END
Tabs:
  'tabstop':
    Number of spaces that a <Tab> character in a file counts for.
  'softtabstop':
    Number of spaces that a <Tab> counts for while performing
    editing operations, like inserting a <Tab> or using <BS>.
  'shiftwidth':
    Number of spaces to use for each step of (auto)indent.
    Used for 'cindent', <<, >>, etc.
  'expandtab':
    Replaces tab characters with spaces.
  'smarttab':
    Better tab semantics, especially after new-lines.
END
let s:wtf_defaults.jobs =<< END
Channel:
  option:
    mode:
      'json' (ch def), 'js', 'nl' (job def), 'raw'
    callback:
      { ch, msg -> ... }
    close_cb:
      { ch -> ... }
    drop:
      'auto': Drop if no callbacks, keep o/w
      'never': Never drop
Jobs:
  option:
    (in|out|err)_mode: See Channel.option.mode
    callback: Generic callback
      { ch, msg -> ... }
    (out|err)_cb: Specific callbacks
      { ch, msg -> ... }
    close_cb:
      { ch -> ... }
    exit_cb:
      { job, status -> ... }
    drop: See Channel.option.drop
END
let s:wtf_defaults.channel = s:wtf_defaults.jobs
let s:wtf_defaults.easyalign =<< END
EasyAlign:
  Shortcuts in alignment mode:
    Int. Key : Command Line  : g:easy_align_delimiters
    ---------:---------------:------------------------
    <C-x>    : /.*/          : <none>
    <C-a>    : a[lcr]+(*|**) : align
    <C-d>    : d[lrc]        : delimiter_align
    <C-i>    : i[ksdn]       : indentation

    <C-[lr]> : [lr][0-9]+    : (left|right)_margin
    <Left>   : <             : stick_to_left
    <Right>  : >             : stick_to_right

    <C-f>    : [gv]/.*/      : filter
    <C-g>    : ig[.*]        : ignore_groups
    <C-u>    : iu[01]        : ignore_unmatched

  stick_to_(left|right)
    Where to stick the delimiter

  Align <C-a>:
    Specifies of each delimited section (not delimiter).
    [lrc]+     : Specify explicitly
    [lrc]+\*   : Repeat the _last_ alignment
    [lrc]+\*\* : Repeat the entire sequence of alignments

  N-th Delimiter:
    By default alignment occurs only on the 1st delimiter of a line
      :EasyAlign =
    Specifying N (a number) will make alignment occur around N-th delimiter
      :EasyAlign N=
    Using * will make it happen across all occurrences of a delimiter
      :EasyAlign *=

  Builtin Delimiters:
    --------------+-------------------------------------
    Delimiter key | Description/Use cases
    --------------+-------------------------------------
       <Space>    | General alignment around whitespaces
          =       | Operators containing equals sign 
          :       | Suitable for formatting JSON or YAML
          .       | Multi-line method chaining
          ,       | Multi-line method arguments
          &       | LaTeX tables (`&`  and  `\\` )
          #       | Ruby/Python comments
          "       | Vim comments
        <Bar>     | Table markdown
    --------------+-------------------------------------
END
let s:wtf_defaults.ea = s:wtf_defaults.easyalign

let s:wtf_defaults.pattern =<< END
Pattern: (Assume \m)

  Magic: (very) \v \m \M \V (not very)
    With \m, unescaped: .* ^$ []

  BNF: (:h pattern)
    <pattern> ::= <branch> ( '\|' <branch> )*
    <branch>  ::= <concat> ( '\&' <concat> )*
    <concat>  ::= <piece>  ( '\&' <piece>  )*
    <piece>   ::= <atom> | ( <atom> <h /multi> )
    <atom>    ::= <h /ordinary-atom>
                | '\(' <pattern> '\)'
                | '\%(' <pattern> '\)'

  <h /multi>
    * \+ \= \?
    \{n,m} \{n,} \{,m} \{}     (As many as possible)
    \{-n,m} \{-n,} \{-,m} \{-} (As few as possible)
    \{n} \{-n}                 (Exactly)

    \@= : Match with 0 width if preceding atom matches
    \@! : Match with 0 width if preceding atom does not match

  <h /ordinary-atom> (Non-standard ones)
"   \< \>   : (/zero-width) Beginning/end of words
"   \zs \ze : (/zero-width) Sets the start/end of match
"   \%^ \%$ : (/zero-width) Begin/end of file
"   \%V     : (/zero-width) Visual area
"   \%#     : (/zero-width) Cursor position
"   \%'m    : (/zero-width) Mark m position
"   \%23l   : (/zero-width) Line 23
"   \%23c   : (/zero-width) Col 23
"   \%23v   : (/zero-width) Virt col 23
END
