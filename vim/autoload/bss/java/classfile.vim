" TODO:
" [X] Constants.Dynamic
" [X] Constants.Module
" [X] Constants.Package
" [ ] Attributes.StackMapTable
" [ ] Attributes.Exceptions
" [X] Attributes.InnerClasses
" [ ] Attributes.EnclosingMethod
" [ ] Attributes.Synthetic
" [X] Attributes.Signature
" [ ] Attributes.SourceDebugExtension
" [ ] Attributes.LineNumberTable
" [ ] Attributes.LocalVariableTable
" [ ] Attributes.LocalVariableTypeTable
" [ ] Attributes.Deprecated
" [ ] Attributes.AnnotationDefault
" [ ] Attributes.BootstrapMethods
" [ ] Field access flags

let s:Constants = bss#Type([
      \   {
      \     'T': 'None',
      \   },
      \   {
      \     'T': 'Class',
      \     'name': v:t_string,
      \   },
      \   {
      \     'T': 'Fieldref',
      \     'class': {'T': 'Class'},
      \     'name_and_type': {'T': 'NameAndType'},
      \   },
      \   {
      \     'T': 'Methodref',
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
      \   {
      \     'T': 'Dynamic',
      \     'bootstrap_method_attr': v:t_string,
      \     'name_and_type': {'T': 'NameAndType'},
      \   },
      \   {
      \     'T': 'Module',
      \     'name': v:t_string,
      \   },
      \   {
      \     'T': 'Package',
      \     'name': v:t_string,
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
      \   {
      \     'T': 'RuntimeVisibleParameterAnnotations',
      \     'parameters': [{
      \       'annotations': s:Annotations,
      \     }],
      \   },
      \   {
      \     'T': 'RuntimeInvisibleParameterAnnotations',
      \     'parameters': [{
      \       'annotations': s:Annotations,
      \     }],
      \   },
      \   {
      \     'T': 'SourceFile',
      \     'sourcefile': v:t_string,
      \   },
      \   {
      \     'T': 'ConstantValue',
      \     'value': v:t_dict,
      \   },
      \   {
      \     'T': 'Code',
      \     'max_stack': v:t_number,
      \     'max_locals': v:t_number,
      \     'code': v:t_blob,
      \     'exception_table': [{
      \       'start_pc': v:t_number,
      \       'end_pc': v:t_number,
      \       'handler_pc': v:t_number,
      \       'catch_type': v:t_number,
      \     }],
      \     'attributes': v:t_list,
      \   },
      \   {
      \     'T': 'InnerClasses',
      \     'classes': [{
      \       'inner_class_info': v:t_dict,
      \       'outer_class_info': v:t_dict,
      \       'inner_name': v:t_string,
      \       'inner_class_access_flags': v:t_number,
      \     }],
      \   },
      \   {
      \     'T': 'Signature',
      \     'signature': v:t_string,
      \   },
      \ ]

let s:Fields = bss#Type([{
      \   'access_flags': v:t_number,
      \   'name': v:t_string,
      \   'descriptor': v:t_string,
      \   'attributes': s:Attributes,
      \ }])

let s:Methods = bss#Type([{
      \   'access_flags': [
      \     'PUBLIC',
      \     'PRIVATE',
      \     'PROTECTED',
      \     'STATIC',
      \     'FINAL',
      \     'SYNCHRONIZED',
      \     'BRIDGE',
      \     'VARARGS',
      \     'NATIVE',
      \     'ABSTRACT',
      \     'STRICT',
      \     'SYNTHETIC',
      \   ],
      \   'name': v:t_string,
      \   'descriptor': v:t_string,
      \   'attributes': s:Attributes,
      \ }])


let s:ClassFile = {
      \   'magic': v:t_blob,
      \   'minor_version': v:t_number,
      \   'major_version': v:t_number,
      \   'constants': s:Constants,
      \   'access_flags': [
      \     'PUBLIC',
      \     'FINAL',
      \     'SUPER',
      \     'INTERFACE',
      \     'ABSTRACT',
      \     'SYNTHETIC',
      \     'ANNOTATION',
      \     'ENUM',
      \   ],
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
  let l:cf.access_flags = s:ParseAccessFlags({
        \   'PUBLIC': 0x0001,
        \   'FINAL': 0x0010,
        \   'SUPER': 0x0020,
        \   'INTERFACE': 0x0200,
        \   'ABSTRACT': 0x0400,
        \   'SYNTHETIC': 0x1000,
        \   'ANNOTATION': 0x2000,
        \   'ENUM': 0x4000,
        \ }, a:bytes.U2())
  let l:cf.this_class = l:cf.GetClassName(a:bytes.U2())
  let l:cf.super_class = l:cf.GetClassName(a:bytes.U2())
  let l:cf.interfaces = range(a:bytes.U2())->map('l:cf.GetClassName(a:bytes.U2())')
  let l:cf.fields = s:ParseFields(a:bytes, l:cf)
  let l:cf.methods = s:ParseMethods(a:bytes, l:cf)
  let l:cf.attributes = s:ParseAttributes(a:bytes, l:cf)
  let l:cf.query = extend(s:Query, {'cf': l:cf})
  return bss#Typed(s:ClassFile, l:cf)
endfunction

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

function! s:ClassFile.GetTypedConstants(T) abort dict
  return copy(self.constants)
        \->filter('v:val.T ==# a:T')
endfunction

function! s:ClassFile.GetAttribute(T) abort dict
  let l:attrs = self.GetAttributes(a:T)
  if len(l:attrs) != 1
    throw 'More than 1 attribute matching ' .. a:T
  endif
  return l:attrs[0]
endfunction

function! s:ClassFile.GetAttributes(T) abort dict
  return copy(self.attributes)
        \->filter('v:val.T ==# a:T')
endfunction

" QUERY API ==================================================================

let s:Query = {}

function! s:Query.Hierarchy() abort dict
  return {self.cf.this_class: [self.cf.super_class] + self.cf.interfaces}
endfunction

function! s:Query.Signature() abort dict
  return self.cf.GetAttribute('Signature')
endfunction

" PARSING ====================================================================

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
      \   17: {b -> [{
      \     'T': 'Dynamic',
      \     'bootstrap_method_attr': b.Idx(),
      \     'name_and_type': b.Idx(),
      \   }]},
      \   19: {b -> [{
      \     'T': 'Module',
      \     'name': b.Idx(),
      \   }]},
      \   20: {b -> [{
      \     'T': 'Package',
      \     'name': b.Idx(),
      \   }]},
      \ }

function! s:ParseConstants(bytes) abort
  let l:constants = [{'T': 'None'}]
  let l:max = a:bytes.U2()
  while len(l:constants) < l:max
    eval l:constants->extend(s:ConstantParsers[a:bytes.U1()](a:bytes))
  endwhile
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

let s:AttributeParsers = {
      \   'RuntimeVisibleAnnotations': {b, c -> {
      \     'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \   }},
      \   'RuntimeInvisibleAnnotations': {b, c -> {
      \     'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \   }},
      \   'RuntimeVisibleParameterAnnotations': {b, c -> {
      \     'parameters': range(b.U1())->map({ -> {
      \       'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \     }})
      \   }},
      \   'RuntimeInvisibleParameterAnnotations': {b, c -> {
      \     'parameters': range(b.U1())->map({ -> {
      \       'annotations': range(b.U2())->map('s:ParseAnnotation(b, c)'),
      \     }})
      \   }},
      \   'SourceFile': {b, c -> {
      \     'sourcefile': c.GetString(b.U2()),
      \   }},
      \   'ConstantValue': {b, c -> {
      \     'value': c.GetConstant(b.U2()),
      \   }},
      \   'Code': {b, c -> {
      \     'max_stack': b.U2(),
      \     'max_locals': b.U2(),
      \     'code': b.Read(b.U4()),
      \     'exception_table': range(b.U2())->map({-> {
      \       'start_pc': b.U2(),
      \       'end_pc': b.U2(),
      \       'handler_pc': b.U2(),
      \       'catch_type': b.U2(),
      \     }}),
      \     'attributes': s:ParseAttributes(b, c),
      \   }},
      \   'InnerClasses': {b, c -> {
      \     'classes': range(b.U2())->map({-> {
      \       'inner_class_info': {i -> i ? c.GetConstant(i) : {}}(b.U2()),
      \       'outer_class_info': {i -> i ? c.GetConstant(i) : {}}(b.U2()),
      \       'inner_name': {i -> i ? c.GetString(i) : ""}(b.U2()),
      \       'inner_class_access_flags': b.U2(),
      \     }}),
      \   }},
      \   'Signature': {b, c -> {
      \     'signature': c.GetString(b.U2()),
      \   }},
      \   'RuntimeVisibleTypeAnnotations': {b, c -> {
      \     'type_annotation': range(b.U2())->map({-> {
      \       'target': s:TypeAnnotationTargetParsers->get(b.U1())(b, c),
      \       'target_path': {
      \         'path': range(b.U1())->map({-> {
      \           'kind': b.U1(),
      \           'arg_index': b.U1(),
      \         }}),
      \       },
      \       'type': c.GetString(b.U2()),
      \       'element_value_pairs': range(a:bytes.U2())->map({i, v -> {
      \         'name': c.GetString(b.U2()),
      \         'value': s:ParseElementValue(b, c),
      \       }}),
      \     }})
      \   }},
      \ }

let s:TypeAnnotationTargetParsers = {
      \   0x00: {b, c -> {
      \     'T': 'type_parameter',
      \     'tag': 0x00,
      \     'type_parameter_index': b.U1(),
      \   }},
      \   0x01: {b, c -> {
      \     'T': 'type_parameter',
      \     'tag': 0x01,
      \     'type_parameter_index': b.U1(),
      \   }},
      \   0x10: {b, c -> {
      \     'T': 'supertype',
      \     'tag': 0x10,
      \     'supertype_index': b.U2(),
      \   }},
      \   0x11: {b, c -> {
      \     'T': 'type_parameter_bound_target',
      \     'tag': 0x11,
      \     'type_parameter_index': b.U1(),
      \     'bound_index': b.U1(),
      \   }},
      \   0x12: {b, c -> {
      \     'T': 'type_parameter_bound_target',
      \     'tag': 0x12,
      \     'type_parameter_index': b.U1(),
      \     'bound_index': b.U1(),
      \   }},
      \   0x13: {b, c -> {
      \     'T': 'empty_target',
      \     'tag': 0x13,
      \   }},
      \   0x14: {b, c -> {
      \     'T': 'empty_target',
      \     'tag': 0x14,
      \   }},
      \   0x15: {b, c -> {
      \     'T': 'empty_target',
      \     'tag': 0x15,
      \   }},
      \   0x16: {b, c -> {
      \     'T': 'formal_parameter_target',
      \     'tag': 0x16,
      \     'formal_parameter_index': b.U1(),
      \   }},
      \   0x17: {b, c -> {
      \     'T': 'throws_target',
      \     'tag': 0x17,
      \     'throws_type_index': b.U2(),
      \   }},
      \ }

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
    let l:ev.array_value = range(a:bytes.U2())->map({-> s:ParseElementValue(a:bytes, a:cf)})
  endif
  return l:ev
endfunction

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

let s:MethodAccessFlags = {
      \ 'PUBLIC': 0x0001,
      \ 'PRIVATE': 0x0002,
      \ 'PROTECTED': 0x0004,
      \ 'STATIC': 0x0008,
      \ 'FINAL': 0x0010,
      \ 'SYNCHRONIZED': 0x0020,
      \ 'BRIDGE': 0x0040,
      \ 'VARARGS': 0x0080,
      \ 'NATIVE': 0x0100,
      \ 'ABSTRACT': 0x0400,
      \ 'STRICT': 0x0800,
      \ 'SYNTHETIC': 0x1000,
      \ }

function! s:ParseMethods(bytes, cf) abort
  return s:Methods(range(a:bytes.U2())->map({i, v -> {
        \   'access_flags': s:ParseAccessFlags(
        \       s:MethodAccessFlags, a:bytes.U2()),
        \   'name': a:cf.GetString(a:bytes.U2()),
        \   'descriptor': a:cf.GetString(a:bytes.U2()),
        \   'attributes': s:ParseAttributes(a:bytes, a:cf),
        \ }}))
endfunction

function! s:ParseAccessFlags(format, flags) abort
  return items(a:format)
        \->filter('and(v:val[1], a:flags) != 0')
        \->map('v:val[0]')
endfunction
