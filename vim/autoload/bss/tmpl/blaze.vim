
function! bss#tmpl#blaze#WORKSPACE(name) abort
  let files = {}
  let files.WORKSPACE = flatten([
        \   s:ext_common()
        \ ])
  return files
endfunction

function! s:workspace(name) abort
  let contents =<< trim eval END
    workspace(name = "{a:name}")
  END
  return contents
endfunction

function! s:ext_common() abort
  let contents =<< trim eval END
    # Some Targets:
    # - @google_bazel_common//third_party/java/guava
    # - @google_bazel_common//third_party/java/auto:value
    # - @google_bazel_common//third_party/java/auto:factory
    # - @google_bazel_common//third_party/java/auto:service
    #
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
  return contents
endfunction
