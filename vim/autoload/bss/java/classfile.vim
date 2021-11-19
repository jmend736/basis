let s:ClassFile = {
      \   'magic': v:t_blob,
      \   'minor_version': v:t_number,
      \   'major_version': v:t_number,
      \   'constants': s:ConstantPool,
      \ }

let s:ConstantPool = {
      \   'count': v:t_number,
      \ }

function! bss#java#classfile#Parse(fname) abort
  let l:bytes = bss#java#bytes#Bytes(a:fname)
  let l:cf = copy(s:ClassFile)
  let l:cf.magic = l:bytes.ReadExpected(4, 0zCAFEBABE)
  let l:cf.minor_version = l:bytes.U2()
  let l:cf.major_version = l:bytes.U2()
  let l:cf.constants = s:ParseConstantPool(l:bytes)
  return l:cf
endfunction

" i is a blob and Parser is a function that accepts bytes and returns a
" dictionary.
let s:Parser = {i, Parser -> #{id: i, Parse: Parser}}
let s:ConstantParsers = [
      \   s:Parser(0z07, {b -> #{
      \     T: 'Class',
      \     name: b.Idx(),
      \   }}),
      \   s:Parser(0z09, {b -> #{
      \     T: 'Fieldref',
      \     class: b.Idx(),
      \     name_and_type: b.Idx(),
      \   }}),
      \   s:Parser(0z0a, {b -> #{
      \     T: 'Methodref',
      \     class: b.Idx(),
      \     name_and_type: b.Idx(),
      \   }}),
      \   s:Parser(0z0b, {b -> #{
      \     T: 'InterfaceMethodref',
      \     class: b.Idx(),
      \     name_and_type: b.Idx(),
      \   }}),
      \   s:Parser(0z08, {b -> #{
      \     T: 'String',
      \     string: b.Idx(),
      \   }}),
      \   s:Parser(0z03, {b -> #{
      \     T: 'Integer',
      \     value: b.U4(),
      \   }}),
      \   s:Parser(0z04, {b -> #{
      \     T: 'Float',
      \     bytes: b.Read(4),
      \   }}),
      \   s:Parser(0z05, {b -> #{
      \     T: 'Long',
      \     high_bytes: b.Read(4),
      \     low_bytes: b.Read(4),
      \   }}),
      \   s:Parser(0z06, {b -> #{
      \     T: 'Double',
      \     high_bytes: b.Read(4),
      \     low_bytes: b.Read(4),
      \   }}),
      \   s:Parser(0z0c, {b -> #{
      \     T: 'NameAndType',
      \     name: b.Idx(),
      \     desc: b.Idx(),
      \   }}),
      \   s:Parser(0z01, {b -> #{
      \     T: 'Utf8',
      \     bytes: b.Utf8(),
      \   }}),
      \   s:Parser(0z0f, {b -> #{
      \     T: 'MethodHandle',
      \     kind: b.U1(),
      \     ref: b.Idx(),
      \   }}),
      \   s:Parser(0z10, {b -> #{
      \     T: 'MethodType',
      \     desc: b.Idx(),
      \   }}),
      \   s:Parser(0z12, {b -> #{
      \     T: 'InvokeDynamic',
      \     bootstrap_method_attr: b.Idx(),
      \     name_and_type: b.Idx(),
      \   }}),
      \ ]
unlet s:Parser

function! s:ParseConstantPool(bytes) abort
  " Parse Values
  let l:constants = []
  let l:count = a:bytes.U2() - 1
  while len(l:constants) < l:count
    let l:id = a:bytes.Read(1)
    let l:result = filter(copy(s:ConstantParsers), {k, v -> v.id == l:id})
    if len(l:result) != 1
      throw 'ERROR(InvalidFormat): Wrong number of matches? ' .. string(l:result)
            \ .. ' for id ' .. string(l:id)
    endif
    let l:const = l:result[0].Parse(a:bytes)
    call add(l:constants, l:const)
    if l:const.T == 'Long' || l:const.T == 'Double'
      call add(l:constants, v:none)
    endif
  endwhile

  " Replace Indexes with values
  for l:constant in l:constants
    if l:constant is v:none
      continue
    endif
    for [l:field, l:value] in items(l:constant)
      if type(l:value) isnot v:t_dict
        continue
      endif
      let l:keys = keys(l:value)
      if len(l:keys) == 1 && l:keys[0] == 'i'
        let l:insert_constant = l:constants[l:value.i - 1]
        if l:insert_constant.T == 'Utf8'
          let l:constant[l:field] = l:insert_constant.bytes
        else
          let l:constant[l:field] = l:insert_constant
        endif
      endif
    endfor
  endfor

  return {'entries': l:constants}
endfunction

let s:file = bss#java#classfile#Parse('main.class')
let i = 0
for c in s:file.constants.entries
  let i += 1
  echom i c
endfor
