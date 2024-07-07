" Bazel/Blaze helper functions
"
"   bss#blaze#BlazeTargets({fname})
"     Return the targets that depend on {fname} directly
"
"   bss#blaze#BlazeTarget()
"     Returns the first target for the current file or '???'
"
"   bss#blaze#TargetClasspath()
"     Returns the classpath for BlazeTarget()
"
"   bss#blaze#CompleteTargets({arg_lead}, {cmd_line}, {cursor_pos})
"     A -complete=customlist compatible function that simply filters the
"     commandline against all targets
"

if !exists('g:bss_blaze_command')
  let g:bss_blaze_cmd = 'blaze'
endif

function! bss#blaze#BlazeTargets() abort
  let l:query = printf(
        \   'same_pkg_direct_rdeps(%s)',
        \   fnamemodify(a:fname, ":p:."),
        \ )

  let l:command = printf(
        \   "%s query '%s'",
        \   g:bss_blaze_cmd,
        \   l:query,
        \ )
  return filter(systemlist(l:command), 'v:val =~# "^//"')
endfunction

function! bss#blaze#BlazeTarget() abort
  return get(bss#blaze#BlazeTargets(expand('%:p')), 0, "???")
endfunction

function! bss#blaze#BlazeGuessCommand(show = v:false) abort
  let l:fname = expand('%:p')

  let l:target = bss#blaze#BlazeTarget()
  if l:target ==# "???"
    echom "Can't find blaze target!"
    return "false"
  endif

  let l:action = 'build'
  if l:fname =~# '\v(_test.cc|Test.java)$' || l:target =~# '\v(_test|Test)$'
    let l:action = 'test'
  elseif l:fname =~# '\v(main.cc|_bin.cc|Bin.java)$' || l:target =~# '\v(_bin|Bin|main|Main)$'
    let l:action = 'run'
  elseif l:fname =~# '\v(_bench.cc)$' || l:target =~# '\v(_bench)$'
    let l:action = 'run -c opt'
  endif

  let l:command = printf(
        \   "%s %s %s",
        \   g:bss_blaze_command,
        \   l:action,
        \   l:target,
        \ )
  if a:show
    echom 'Using:' l:command
  endif
  return l:command
endfunction

function! bss#blaze#TargetClasspath() abort
  let l:target = bss#blaze#BlazeTarget()
  if l:target ==# "???"
    echom "Can't find blaze target!"
    return ""
  endif

  let l:lines = systemlist(printf('blaze print_action "%s"', l:target))
  let l:jars = filter(l:lines, {_, v -> v =~# '^\s\+\(outputjar\|classpath\): "[^"]*"'})
        \->map({_, v -> matchlist(v, '"\([^"]*\)"')[1]})
  return join(l:jars, ':')
endfunction

function! bss#blaze#CompleteTargets(arg_lead, cmd_line, cursor_pos) abort
  if a:arg_lead =~ '^//.*'
    return systemlist(printf('%s query ... 2>&1', g:bss_blaze_command))
          \->filter('v:val =~# "' .. a:arg_lead .. '"')
  endif
endfunction

function! bss#blaze#MakeJavaWorkspace(name) abort

  let files = {}

  let files.WORKSPACE =<< trim eval END
    load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

    GOOGLE_BAZEL_COMMON_COMMIT = "b41d50b173bc8121812485410899a241be7815cf";
    GOOGLE_BAZEL_COMMON_SHA256 = "e9c428bd82741a5111df51de6609f450018ba6174d73f9d05954a0b16e4894dd";
    http_archive(
        name = "google_bazel_common",
        sha256 = GOOGLE_BAZEL_COMMON_SHA256,
        strip_prefix = "bazel-common-%s" % GOOGLE_BAZEL_COMMON_COMMIT,
        urls = ["https://github.com/google/bazel-common/archive/%s.zip" % GOOGLE_BAZEL_COMMON_COMMIT],
    )

    load("@google_bazel_common//:workspace_defs.bzl", "google_common_workspace_rules")

    google_common_workspace_rules()
  END

  let files.BUILD =<< trim eval END
    java_binary(
      name = "{a:name}",
      srcs = ["{a:name}.java"],
      main_class = "{a:name}",
      deps = [
        "@google_bazel_common//third_party/java/guava"
      ],
    )
  END

  let files[a:name] =<< trim eval END
    import com.google.common.collect.ImmutableList;

    public class {a:name} {
      public static void main(String[] args) {
        System.out.println(ImmutableList.of(1, 3, 2));
      }
    }
  END

  for [filename, contents] in items(files)
    if !filereadable(filename)
      call writefile(contents, filename)
      echom $">>> Wrote {filename}"
    endif
  endfor

endfunction
