function! bss#coq#RunBlocks() abort
  let l:blocks = bss#md#GetBlocks()
  let l:next_block = v:none
  for l:block in reverse(l:blocks)
    let l:is_coq =
          \ l:block['lang'] ==# 'coq'
    let l:has_output =
          \ l:next_block isnot v:none
          \ && l:next_block['lang'] ==# 'coq:output'

    if l:is_coq
      let l:bufnr = bufnr('')
      let l:results = systemlist('coqtop', l:block['lines'])
      if l:has_output
        call deletebufline(l:bufnr, l:next_block['span'][0], l:next_block['span'][1])
        call appendbufline(l:bufnr, l:next_block['span'][0] - 1, l:results)
      else
        call appendbufline(
              \ l:bufnr,
              \ l:block['span'][1] + 1,
              \ ['', '```coq:output'] + l:results + ['```'])
      endif
    endif

    let l:next_block = l:block
  endfor
endfunction
