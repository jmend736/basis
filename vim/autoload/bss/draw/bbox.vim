"
" bss#draw#bbox#BBox(xmin, ymin, xmax, ymax)
"   Defines a bounding box

let s:Point = [v:t_number, v:t_number]

let s:BBox = {
      \   'bl': s:Point,
      \   'tr': s:Point,
      \ }

function! bss#draw#bbox#BBox(...) abort
  let l:T = a:0 > 0 ? bss#Transpose(a:1) : []
  return copy(s:BBox)->extend({
        \   'bl': l:T->copy()->map('min(v:val)'),
        \   'tr': l:T->copy()->map('max(v:val)'),
        \ })
endfunction

function! s:BBox.Plus(bb) abort dict
  return bss#draw#bbox#BBox([self.bl, self.tr, a:bb.bl, a:bb.tr])
endfunction
