function! bss#ensure#Func(Val) abort
  if type(a:Val) != v:t_func
    throw 'ERROR(WrongType): Expected Funcref! '
  endif
  return a:Val
endfunction

function! bss#ensure#Str(Val) abort
  if type(a:Val) != v:t_string
    throw 'ERROR(WrongType): Expected String!'
  endif
  return a:Val
endfunction
