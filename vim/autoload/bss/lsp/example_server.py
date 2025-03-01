import sys
import json


def log(*args, **kwargs):
    print(">>>", *args, file=sys.stderr, **kwargs)


def hello(*args, **kwargs):
    return 10


def f(x):
    return int(x) + 1


methods = {"hello": hello, "f": f}


class Missing:
    """Represents a missing value that is allowed to be missing."""

    pass


def response(req_id, result, error):
    resp = dict()

    if req_id is not Missing:
        resp.update({"id": req_id})

    if error is None:
        resp["result"] = result
    else:
        resp["error"] = {"code": -32000, "message": error}

    print(json.dumps(resp))


def apply(f, params):
    if isinstance(params, list):
        return f(*params)
    elif isinstance(params, dict):
        return f(**params)
    elif params is Missing:
        return f()
    else:
        raise Exception(f'Invalid params: {params}')


def handle(line):
    try:
        req_raw = json.loads(line)
    except Exception as e:
        return response(Missing, None, repr(e))
    req_id = req_raw.get("id", Missing)
    req_params = req_raw.get("params", Missing)
    try:
        method_name = req_raw["method"]
        method = methods[method_name]
        return response(req_id, apply(method, req_params), None)
    except Exception as e:
        return response(req_id, None, repr(e))


import argparse

argp = argparse.ArgumentParser()

argp.add_argument("--loop", type=bool, default=False)
args = argp.parse_args()

if args.loop:
    while True:
        handle(input())
else:
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f"}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": [1, 2, 3]}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": {"a": 2}}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": {"x": 2}}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": [10]}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": [10]}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": [11]}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": [12]}')
    handle('{"jsonrpc": "2.0", "id": 1, "method": "f", "params": [13]}')
    handle('{"jsonrpc": "2.0", "no": 2}')
    handle('{"jsonrpc": "2.0", "no": 2, "id": 2}')
    handle("hello world :D")
