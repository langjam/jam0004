
from graphica.node import Node, Selector, SelectorOption

def object_of(arr):
    return '{' + ''.join(arr) + '}'

def array_object(arr):
    return object_of(prop(k, v) for k, v in enumerate(arr))

def save_pre_node(node):
    ret = {}
    ret['type'] = 'node'
    ret['pos'] = node.pos
    ret['size'] = node.size
    ret['color'] = list(node.color)
    ret['children'] = [save_pre(i) for i in node.list if not isinstance(i, SelectorOption)]
    return ret

def save_pre(node):
    if isinstance(node, Selector):
        ret = save_pre_node(node)
        ret['type'] = 'selector'
        ret['text'] = node.text
        return ret
    if isinstance(node, Node):
        return save_pre_node(node)

def load_post(self, thing):
    if thing['type'] == 'node':
        ret = Node(thing['pos'], thing['size'])
        ret.color = thing['color']
        ret.list = [load_post(self, i) for i in thing['children']]
        ret.config = self.config
        return ret
    elif thing['type'] == 'selector':
        ret = Selector(
            thing['pos'],
            thing['size'],
            thing['text']
        )
        ret.color = thing['color']
        ret.list = [load_post(self, i) for i in thing['children']]
        ret.then = self.then
        ret.into = self.selected
        ret.config = self.config
        return ret
    raise Exception("bad load")