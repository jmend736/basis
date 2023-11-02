"
" bss#draw#bbox#BBox(xmin, ymin, xmax, ymax)
"   Defines a bounding box
"
" Descriptors:
"
"   descriptor:
"     vim type (eg. v:t_list, v:t_number, ...)
"       the {value}'s type with be checked aginst the {vim type}
"     a list of descriptor(s)
"       assert {value} is a list, and its entries match any of {descriptor(s)}
"     a map with descriptor values
"       asser all keys in {map} exist in {value}, and the {descriptor} matches
"       the key's corresponding value.
"     a function returned by bss#type#Type()
"       defer to the type checker
"     a string
"       the string will be matched literally
"     any function
"       ensure {value} has type v:t_func

function! bss#draw#bbox#BBox(xmin, ymin, xmax, ymax) abort
  let l:botleft  = [min([a:xmin, a:xmax]), min([a:ymin, a:ymax])]
  let l:topright = [max([a:xmin, a:xmax]), max([a:ymin, a:ymax])]
  return deepcopy(s:BBox)->extend({
        \   'bl': l:botleft,
        \   'tr': l:topright,
        \ })
endfunction

let s:Point = [v:t_number, v:t_number]

let s:BBox = {
      \   'bl': s:Point,
      \   'tr': s:Point,
      \ }

echom bss#draw#bbox#BBox(1, 1, 1, 1)
