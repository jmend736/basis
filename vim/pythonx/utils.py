from pathlib import Path
import re

def autoload(s, path):
    s.rv = maybe_autoload(path)

def maybe_autoload(fn):
    P = str(Path(fn).resolve())
    valid = '/autoload/' in P and P.endswith('.vim')
    if not valid:
        return ''
    [before, _, after] = P.partition('/autoload/')
    ctx = after.strip('/').replace('/', '#')
    ctx = re.sub('\.vim$', '', ctx)
    return ctx + '#'
