
set -l basis_path (realpath (git rev-parse --show-toplevel))

set -l basis_functions $basis_path/fish/functions
set -l basis_completions $basis_path/fish/completions

if not contains $basis_functions $fish_functions_path
  set -g -a fish_functions_path $basis_path/fish/functions
end

if not contains $basis_completions $fish_complete_path
  set -g -a fish_complete_path $basis_path/fish/completions
end
