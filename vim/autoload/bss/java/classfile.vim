let s:ConstantPool = {
      \   'count': v:t_number,
      \   'entries': {v:t_number: v:t_dict},
      \ }

let s:Attributes = {
      \   'count': v:t_number,
      \   'entries': [v:t_dict],
      \ }

let s:Fields = {
      \   'count': v:t_number,
      \   'entries': [v:t_dict],
      \   'attributes': s:Attributes,
      \ }

let s:Methods = {
      \   'count': v:t_number,
      \   'entries': [v:t_dict],
      \   'attributes': s:Attributes,
      \ }

let s:ClassFile = {
      \   'magic': v:t_blob,
      \   'minor_version': v:t_number,
      \   'major_version': v:t_number,
      \   'constants': s:ConstantPool,
      \   'access_flags': v:t_number,
      \   'this_class': v:t_string,
      \   'super_class': v:t_string,
      \   'interfaces': [v:t_string],
      \   'fields': s:Fields,
      \   'methods': s:Methods,
      \   'attributes': s:Attributes,
      \ }

function! bss#java#classfile#Parse(fname) abort
  let l:bytes = bss#java#bytes#Bytes(a:fname)
  return bss#java#classfile#ParseBytes(l:bytes)
endfunction

function! bss#java#classfile#ParseBytes(bytes) abort
  let l:cf = copy(s:ClassFile)
  let l:cf.magic = a:bytes.ReadExpected(4, 0zCAFEBABE)
  let l:cf.minor_version = a:bytes.U2()
  let l:cf.major_version = a:bytes.U2()
  let l:cf.constants = s:ParseConstantPool(a:bytes)
  let l:cf.access_flags = a:bytes.U2()
  let l:ReadName = { -> l:cf.constants.GetClassName(a:bytes.U2()) }
  let l:cf.this_class = l:ReadName()
  let l:cf.super_class = l:ReadName()
  let l:cf.interfaces = range(a:bytes.U2())->map('l:ReadName()')
  let l:cf.fields = s:ParseFields(a:bytes, l:cf.constants)
  let l:cf.methods = s:ParseMethods(a:bytes, l:cf.constants)
  let l:cf.attributes = s:ParseAttributes(a:bytes, l:cf.constants)
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

" Handler accepts 2 args: the {id} and {const} dict
function! s:ConstantPool.ForEach(Handler) abort dict
  for l:id in range(1, self.count + 1)
    if has_key(self.entries, l:id)
      call a:Handler(l:id, self.entries[l:id])
    endif
  endfor
endfunction

function! s:ConstantPool.GetClassName(idx) abort dict
  if !has_key(self.entries, a:idx)
    throw 'Invalid index!'
  endif
  let l:v = self.entries->get(a:idx)
  if l:v.T != 'Class'
    throw 'Not a class!'
  endif
  return l:v.name
endfunction

function! s:ConstantPool.GetString(idx) abort dict
  if !has_key(self.entries, a:idx)
    throw 'Invalid index!'
  endif
  let l:v = self.entries->get(a:idx)
  if l:v.T != 'Utf8'
    throw 'Not a Utf8 constant!'
  endif
  return l:v.bytes
endfunction

function! s:ParseConstantPool(bytes) abort
  " Parse Values
  let l:constants = copy(s:ConstantPool)
  let l:constants.entries = {}
  let l:constants.count = a:bytes.U2() - 1
  let l:next = 1
  while l:next < (l:constants.count + 1)
    let l:id = a:bytes.Read(1)
    let l:result = filter(copy(s:ConstantParsers), {k, v -> v.id == l:id})
    if len(l:result) != 1
      throw 'ERROR(InvalidFormat): Wrong number of matches? '
            \ .. string(l:result)
            \ .. ' for id ' .. string(l:id)
    endif
    let l:const = l:result[0].Parse(a:bytes)
    let l:constants.entries[l:next] = l:const
    let l:next += 1
    if l:const.T == 'Long' || l:const.T == 'Double'
      let l:constants.entries[l:next] = {'T': 'None'}
      let l:next += 1
    endif
  endwhile

  " Replace Indexes with values
  for [l:n, l:constant] in items(l:constants.entries)
    for [l:field, l:value] in items(l:constant)
      if type(l:value) isnot v:t_dict
        continue
      endif
      let l:keys = keys(l:value)
      if len(l:keys) == 1 && l:keys[0] == 'i'
        let l:insert_constant = l:constants.entries[l:value.i]
        if l:insert_constant.T == 'Utf8'
          let l:constant[l:field] = l:insert_constant.bytes
        else
          let l:constant[l:field] = l:insert_constant
        endif
      endif
    endfor
  endfor

  return l:constants
endfunction

function! s:ParseAnnotation(bytes, constants) abort
  return {
      \   'type': a:constants.GetString(a:bytes.U2()),
      \   'element_value_pairs': range(a:bytes.U2())->map({i, v -> {
      \     'name': a:constants.GetString(a:bytes.U2()),
      \     'value': s:ParseElementValue(a:bytes, a:constants),
      \   }}),
      \ }
endfunction

function! s:ParseElementValue(bytes, constants) abort
  let l:ev = {}
  let l:ev.tag = nr2char(a:bytes.U1())
  if l:ev.tag =~# '[BCDFIJSZs]'
    let l:ev.const_value = a:constants.entries->get(a:bytes.U2())
  elseif l:ev.tag =~# '[e]'
    let l:ev.enum_const_value = {
          \   'type_name': a:constants.GetString(a:bytes.U2()),
          \   'const_name': a:constants.GetString(a:bytes.U2()),
          \ }
  elseif l:ev.tag =~# '[c]'
    let l:ev.const_value = a:constants.GetString(a:bytes.U2())
  elseif l:ev.tag =~# '[@]'
    let l:ev.annotation_value = s:ParseAnnotation(a:bytes, a:constants)
  elseif l:ev.tag =~# '\['
    let l:ev.array_value = s:ParseElementValue(a:bytes, a:constants)
  endif
  return l:ev
endfunction

let s:AttributeParsers = {
      \   'RuntimeVisibleAnnotations': {b, c -> {
      \     'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \   }},
      \ }

function! s:ParseAttributes(bytes, constants) abort
  let l:attrs = copy(s:Attributes)
  let l:attrs.count = a:bytes.U2()
  let l:attrs.entries = []
  for l:i in range(l:attrs.count)
    let l:attr = {}
    let l:attr.name = a:constants.GetString(a:bytes.U2())
    let l:attr.length = a:bytes.U4()
    if has_key(s:AttributeParsers, l:attr.name)
      call extend(l:attr, s:AttributeParsers->get(l:attr.name)(a:bytes, a:constants))
    else
      let l:attr.info = a:bytes.Read(l:attr.length)
    endif
    call add(l:attrs.entries, l:attr)
  endfor
  return l:attrs
endfunction

function! s:ParseFields(bytes, constants) abort
  return range(a:bytes.U2())->map({i, v -> {
        \   'access_flags': a:bytes.U2(),
        \   'name': a:constants.GetString(a:bytes.U2()),
        \   'descriptor': a:constants.GetString(a:bytes.U2()),
        \   'attributes': s:ParseAttributes(a:bytes, a:constants),
        \ }})
endfunction

function! s:ParseMethods(bytes, constants) abort
  return range(a:bytes.U2())->map({i, v -> {
        \   'access_flags': a:bytes.U2(),
        \   'name': a:constants.GetString(a:bytes.U2()),
        \   'descriptor': a:constants.GetString(a:bytes.U2()),
        \   'attributes': s:ParseAttributes(a:bytes, a:constants),
        \ }})
endfunction
