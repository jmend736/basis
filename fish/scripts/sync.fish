# Copyright (c) 2026 Julian Mendoza
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function sync
    set -l cmd $argv[1]
    set -l args $argv[2..]
    switch $cmd

        # Entrypoint
        case ''
            sync syncdir \
                --from=$HOME/.config/fish/functions \
                --to=(sync basepath)/fish/functions

            sync syncdir \
                --from=$HOME/.config/fish/completions \
                --to=(sync basepath)/fish/completions

        # For every file present in {to} that's in {from} and has been
        # modified, copy the file from {from} to {to}.
        case syncdir
            argparse 'f/from=' 't/to=' -- $args
            pushd $_flag_to
            for fname in *
                if not test -f $_flag_from/$fname
                    printf 'sync skipping %s\n' $_flag_from/$fname
                    continue
                end
                if not diff $_flag_from/$fname $_flag_to/$fname >/dev/null
                    printf 'sync %s updated\n' $_flag_to/$fname
                    cp $_flag_from/$fname $_flag_to/$fname
                end
            end
            popd

        # Get the current basename
        case basepath
            if not set -l basis_path (git rev-parse --show-toplevel)
                echo "Must be run from from the basis repo directory!"
                return 1
            end
            echo $basis_path

    end
end

sync
