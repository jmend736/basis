# Copyright (c) 2023 Julian Mendoza
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

set -l script (realpath (status filename))
set -l functions (dirname (dirname $script))/functions

if functions -q save
    functions save
    if test (read -n 1 -P 'Override current save command? y/[n]: ') != y
        echo "Ok stopping..."
        exit
    end
end

source (echo '
function save -w functions
    if not functions -q $argv[1]
        echo "Error: Argument must be a function name!"
        exit 1
    end
    functions --no-details $argv[1] > '$functions'/$argv[1].fish
end
' | psub)
funcsave save
echo "Installed!"
