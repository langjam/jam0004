from node import SelectorOption

def do_add(*args):
    r = 0
    for i in args:
        r += i
    return r

def do_sub(*args):
    r = args[0]
    for i in args[1:]:
        r -= i
    return r

def do_mul(*args):
    r = 1
    for i in args:
        r *= i
    return r

def do_div(*args):
    r = args[0]
    for i in args[1:]:
        r /= i
    return r

env = {
    'root': None,
    'do': None,
    'add': do_add,
    'sub': do_sub,
    'mul': do_mul,
    'div': do_div,
}

def run(node):
    args = [run(i) for i in node.list if not isinstance(i, SelectorOption)]
    if hasattr(node, 'text'):
        value = ''
        def do_show(*args):
            nonlocal value
            for arg in args:
                value += str(arg)
        def transform(str):
            for i in range(len(args)):
                str = str.replace(f'${i+1}', f'arg{i+1}')
            str = str.replace(f'$#', 'argc')
            str = str.replace(f'$*', '*argv')
            return str
        lenv = {
            'argv': args,
            'argc': len(args),
            'print': do_show,
            'write': do_show,
            'out': do_show,
            'show': do_show,
        }
        for i, v in enumerate(args):
            lenv[f'arg{i+1}'] = v
        try:
            ret = eval(transform(node.text), env, lenv) 
        except Exception as e:
            ret = None
        finally:
            node.value = value
        if node.value == '' and ret is not None:
            node.value = str(ret)
        return ret
    else:
        return None