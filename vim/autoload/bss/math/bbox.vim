let s:Point = [v:t_number, v:t_number]

let s:BBox = {
      \   'bl': s:Point,
      \   'tr': s:Point,
      \ }

""
" Create an axis aligned bounding box.
"
" bss#math#bbox#BBox()
" :   2D BBox of just [0, 0]
"
" bss#math#bbox#BBox(point: list<number>)
" :   2D BBox of just {point}
"
" bss#math#bbox#BBox(point1: list<number>, ...)
" :   nD BBox with extends defined by min/max of all points
"
" bss#math#bbox#BBox([point1, ...]: list<list<number>>)
" :   nD BBox with extends defined by min/max of all points
"
" bss#math#bbox#BBox(text: string)
" :   2D BBox of [0, 0] to [len(text), 1]
"
function! bss#math#bbox#BBox(...) abort
  if a:0 == 0
    return bss#math#bbox#BBoxFromPoints([0, 0])
  elseif a:0 == 1 && type(a:1) == v:t_string
      return bss#math#bbox#BBoxFromText(a:1)
  elseif a:0 == 1 && type(a:1) == v:t_list
    return bss#math#bbox#BBoxFromPoints(a:1)
  elseif a:0 > 1
    return bss#math#bbox#BBoxFromPoints(a:000)
  endif
endfunction

""
" Define a bounding box by using min/max of all points in {pts}.
"
function! bss#math#bbox#BBoxFromPoints(pts) abort
  let l:pts_T = bss#Transpose(a:pts)
  return copy(s:BBox)->extend({
        \   'bl': l:pts_T->copy()->map('min(v:val)'),
        \   'tr': l:pts_T->copy()->map('max(v:val)'),
        \ })
endfunction

""
" Define a bounding box by using size of text.
"
function! bss#math#bbox#BBoxFromText(text) abort
  return bss#math#bbox#BBoxFromPoints([[0, 0], [len(a:text), 1]])
endfunction

""
" Calculate the extent along some axis
"
" bb.Extent()
" :   is equivalent to bb.Extent(0)
"
" bb.Extent(axis: number)
" :   gets the extent of axis
"
" bb.Extent([a0, a1, ...])
" :   returns an array of the extents
"
" bb.Extent(a0, a1, ...)
" :   returns an array of the extents
"
function! s:BBox.Extent(...) abort dict
  if a:0 == 0
    return self.Extent(0)
  elseif a:0 == 1 && type(a:1) == v:t_number
    return self.tr[a:1] - self.bl[a:1]
  elseif a:0 == 1 && type(a:1) == v:t_list
    return copy(a:1)->map('self.Extent(v:val)')
  elseif a:0 > 1
    return copy(a:000)->map('self.Extent(v:val)')
  else
    throw printf('ERROR(WrongType): Invalid arguments to Extent: %s', string(a:000))
  endif
endfunction

""
" Convert the BBox to a Vector (list of numbers), which defines the extents
"
function! s:BBox.ToVec() abort dict
  return bss#VecPlus(bss#VecTimes(-1, self.bl), self.tr)
endfunction

""
" Merge {bbox} with this one.
"
" Commutative Semigroup
" -   Commutative: A x B == B x A
" -   Associative: A x (B x C) == (A x B) x C
"
function! s:BBox.Merge(bbox) abort dict
  return bss#math#bbox#BBoxFromPoints([self.bl, self.tr, a:bbox.bl, a:bbox.tr])
endfunction

function! s:BBox.Stack(bbs) abort
  let l:args = [self, a:bbs]
  return {
        \   'Above': function('s:BBox_Stack_Above', l:args),
        \   'Below': function('s:BBox_Stack_Below', l:args),
        \   'Left':  function('s:BBox_Stack_Left',  l:args),
        \   'Right': function('s:BBox_Stack_Right', l:args),
        \   'V':     function('s:BBox_Stack_Above', l:args),
        \   'H':     function('s:BBox_Stack_Right', l:args),
        \ }
endfunction

function! s:BBox_Stack_Above(bb, rest) abort
endfunction

function! s:BBox_Stack_Below(bb, rest) abort
endfunction

function! s:BBox_Stack_Left(bb, rest) abort
endfunction

function! s:BBox_Stack_Right(bb, rest) abort
endfunction

if exists('g:dev_bss_bbox')
  let BB = function('bss#math#bbox#BBox')
  let BB1 = BB()
  let BB2 = BB([[1, 2, 3], [2, 1, 2]])
endif
