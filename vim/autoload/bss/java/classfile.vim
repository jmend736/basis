let s:Constants = bss#Type([
      \   {
      \     'T': 'None',
      \   },
      \   {
      \     'T': 'Class',
      \     'name': v:t_string,
      \   },
      \   {
      \     'T': 'FieldRef',
      \     'class': {'T': 'Class'},
      \     'name_and_type': {'T': 'NameAndType'},
      \   },
      \   {
      \     'T': 'MethodRef',
      \     'class': {'T': 'Class'},
      \     'name_and_type': {'T': 'NameAndType'},
      \   },
      \   {
      \     'T': 'InterfaceMethodref',
      \     'class': {'T': 'Class'},
      \     'name_and_type': {'T': 'NameAndType'},
      \   },
      \   {
      \     'T': 'String',
      \     'string': v:t_string,
      \   },
      \   {
      \     'T': 'Integer',
      \     'value': v:t_number,
      \   },
      \   {
      \     'T': 'Float',
      \     'value': v:t_number,
      \   },
      \   {
      \     'T': 'Long',
      \     'high_bytes': v:t_blob,
      \     'low_bytes': v:t_blob,
      \   },
      \   {
      \     'T': 'Double',
      \     'high_bytes': v:t_blob,
      \     'low_bytes': v:t_blob,
      \   },
      \   {
      \     'T': 'NameAndType',
      \     'name': v:t_string,
      \     'desc': v:t_string,
      \   },
      \   {
      \     'T': 'Utf8',
      \     'bytes': v:t_string,
      \   },
      \   {
      \     'T': 'MethodHandle',
      \     'kind': v:t_number,
      \     'ref': {'T': '<unknown>'},
      \   },
      \   {
      \     'T': 'MethodType',
      \     'desc': v:t_string,
      \   },
      \   {
      \     'T': 'InvokeDynamic',
      \     'bootstrap_method_attr': v:t_string,
      \     'name_and_type': {'T': 'NameAndType'},
      \   },
      \ ])

let s:Annotations = [
      \   {
      \     'type': v:t_string,
      \     'element_value_pairs': [{
      \       'name': v:t_string,
      \       'value': {
      \         'tag': v:t_string,
      \       },
      \     }],
      \   }
      \ ]

""
" RuntimeVisibleAnnotations:
"   - Limited to class, field or method annotations
"   - At most 1 of these can be present per structure
"
let s:Attributes = [
      \   {
      \     'T': v:t_string,
      \     'info': v:t_blob,
      \   },
      \   {
      \     'T': 'RuntimeVisibleAnnotations',
      \     'annotations': s:Annotations,
      \   },
      \   {
      \     'T': 'RuntimeInvisibleAnnotations',
      \     'annotations': s:Annotations,
      \   },
      \ ]

let s:Fields = bss#Type([{
      \   'access_flags': v:t_number,
      \   'name': v:t_string,
      \   'descriptor': v:t_string,
      \   'attributes': s:Attributes,
      \ }])

let s:Methods = bss#Type([{
      \   'access_flags': v:t_number,
      \   'name': v:t_string,
      \   'descriptor': v:t_string,
      \   'attributes': s:Attributes,
      \ }])


let s:ClassFile = {
      \   'magic': v:t_blob,
      \   'minor_version': v:t_number,
      \   'major_version': v:t_number,
      \   'constants': s:Constants,
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
  let l:cf.constants = s:ParseConstants(a:bytes)
  let l:cf.access_flags = a:bytes.U2()
  let l:cf.this_class = l:cf.GetClassName(a:bytes.U2())
  let l:cf.super_class = l:cf.GetClassName(a:bytes.U2())
  let l:cf.interfaces = range(a:bytes.U2())->map('l:cf.GetClassName(a:bytes.U2())')
  let l:cf.fields = s:ParseFields(a:bytes, l:cf)
  let l:cf.methods = s:ParseMethods(a:bytes, l:cf)
  let l:cf.attributes = s:ParseAttributes(a:bytes, l:cf)
  return bss#Typed(s:ClassFile, l:cf)
endfunction

let s:ConstantParsers = {
      \   7: {b -> [{
      \     'T': 'Class',
      \     'name': b.Idx(),
      \   }]},
      \   9: {b -> [{
      \     'T': 'Fieldref',
      \     'class': b.Idx(),
      \     'name_and_type': b.Idx(),
      \   }]},
      \   10: {b -> [{
      \     'T': 'Methodref',
      \     'class': b.Idx(),
      \     'name_and_type': b.Idx(),
      \   }]},
      \   11: {b -> [{
      \     'T': 'InterfaceMethodref',
      \     'class': b.Idx(),
      \     'name_and_type': b.Idx(),
      \   }]},
      \   8: {b -> [{
      \     'T': 'String',
      \     'string': b.Idx(),
      \   }]},
      \   3: {b -> [{
      \     'T': 'Integer',
      \     'value': b.U4(),
      \   }]},
      \   4: {b -> [{
      \     'T': 'Float',
      \     'bytes': b.Read(4),
      \   }]},
      \   5: {b -> [{
      \     'T': 'Long',
      \     'high_bytes': b.Read(4),
      \     'low_bytes': b.Read(4),
      \   }, {
      \     'T': 'None'
      \   }]},
      \   6: {b -> [{
      \     'T': 'Double',
      \     'high_bytes': b.Read(4),
      \     'low_bytes': b.Read(4),
      \   }, {
      \     'T': 'None'
      \   }]},
      \   12: {b -> [{
      \     'T': 'NameAndType',
      \     'name': b.Idx(),
      \     'desc': b.Idx(),
      \   }]},
      \   1: {b -> [{
      \     'T': 'Utf8',
      \     'bytes': b.Utf8(),
      \   }]},
      \   15: {b -> [{
      \     'T': 'MethodHandle',
      \     'kind': b.U1(),
      \     'ref': b.Idx(),
      \   }]},
      \   16: {b -> [{
      \     'T': 'MethodType',
      \     'desc': b.Idx(),
      \   }]},
      \   18: {b -> [{
      \     'T': 'InvokeDynamic',
      \     'bootstrap_method_attr': b.Idx(),
      \     'name_and_type': b.Idx(),
      \   }]},
      \ }

" {idx}: 1-indexed constant entry index
function! s:ClassFile.GetConstant(idx) abort dict
  if a:idx > len(self.constants)
    throw 'ERROR(ArgumentError): Invalid constant index ' .. a:idx
  endif
  return self.constants->get(a:idx)
endfunction

function! s:ClassFile.GetTypedConstant(T, idx) abort dict
  let l:const = self.GetConstant(a:idx)
  if l:const.T !=# a:T
    throw printf(
          \ 'ERROR(TypeError): Expected %s at index %s, but got %s',
          \ a:T, a:idx, l:const.T)
  endif
  return l:const
endfunction

function! s:ClassFile.GetClassName(idx) abort dict
  return self.GetTypedConstant('Class', a:idx).name
endfunction

function! s:ClassFile.GetString(idx) abort dict
  return self.GetTypedConstant('Utf8', a:idx).bytes
endfunction

function! s:ParseConstants(bytes) abort
  let l:constants = [{'T': 'None'}]
  for _ in range(a:bytes.U2() - 1)
    eval l:constants->extend(s:ConstantParsers[a:bytes.U1()](a:bytes))
  endfor
  for l:const in l:constants
    for [l:key, l:index] in copy(l:const)
          \->filter({_, v -> type(v) == v:t_dict && keys(v) == ['&']})
          \->items()
      let l:value = l:constants[l:index['&']]
      let l:const[l:key] = (l:value.T == 'Utf8') ? l:value.bytes : l:value
    endfor
  endfor
  return l:constants
endfunction

function! s:ParseAnnotation(bytes, cf) abort
  return {
      \   'type': a:cf.GetString(a:bytes.U2()),
      \   'element_value_pairs': range(a:bytes.U2())->map({i, v -> {
      \     'name': a:cf.GetString(a:bytes.U2()),
      \     'value': s:ParseElementValue(a:bytes, a:cf),
      \   }}),
      \ }
endfunction

function! s:ParseElementValue(bytes, cf) abort
  let l:ev = {}
  let l:ev.tag = nr2char(a:bytes.U1())
  if l:ev.tag =~# '[BCDFIJSZs]'
    let l:ev.const_value = a:cf.constants->get(a:bytes.U2())
  elseif l:ev.tag =~# '[e]'
    let l:ev.enum_const_value = {
          \   'type_name': a:cf.GetString(a:bytes.U2()),
          \   'const_name': a:cf.GetString(a:bytes.U2()),
          \ }
  elseif l:ev.tag =~# '[c]'
    let l:ev.const_value = a:cf.GetString(a:bytes.U2())
  elseif l:ev.tag =~# '[@]'
    let l:ev.annotation_value = s:ParseAnnotation(a:bytes, a:cf)
  elseif l:ev.tag =~# '\['
    let l:ev.array_value = s:ParseElementValue(a:bytes, a:cf)
  endif
  return l:ev
endfunction

let s:AttributeParsers = {
      \   'RuntimeVisibleAnnotations': {b, c -> {
      \     'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \   }},
      \   'RuntimeInvisibleAnnotations': {b, c -> {
      \     'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \   }},
      \ }

function! s:ParseAttributes(bytes, cf) abort
  let l:attributes = []
  for _ in range(a:bytes.U2())
    let l:attr = {
          \   'T': a:cf.GetString(a:bytes.U2()),
          \   'length': a:bytes.U4(),
          \ }
    if has_key(s:AttributeParsers, l:attr.T)
      call extend(l:attr, s:AttributeParsers->get(l:attr.T)(a:bytes, a:cf))
    else
      let l:attr.info = a:bytes.Read(l:attr.length)
    endif
    eval l:attributes->add(l:attr)
  endfor
  return l:attributes
endfunction

function! s:ParseFields(bytes, cf) abort
  return s:Fields(range(a:bytes.U2())->map({i, v -> {
        \   'access_flags': a:bytes.U2(),
        \   'name': a:cf.GetString(a:bytes.U2()),
        \   'descriptor': a:cf.GetString(a:bytes.U2()),
        \   'attributes': s:ParseAttributes(a:bytes, a:cf),
        \ }}))
endfunction

function! s:ParseMethods(bytes, cf) abort
  return s:Methods(range(a:bytes.U2())->map({i, v -> {
        \   'access_flags': a:bytes.U2(),
        \   'name': a:cf.GetString(a:bytes.U2()),
        \   'descriptor': a:cf.GetString(a:bytes.U2()),
        \   'attributes': s:ParseAttributes(a:bytes, a:cf),
        \ }}))
endfunction

