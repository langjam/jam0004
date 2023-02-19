from graphica.node import SelectorOption

import math

class Env:
    def __init__(self):
        self.stack = []
        self.defs = dict()

    def run(self, word):
        if word == '' or word == 'root':
            pass
        elif self.depth != 0:
            if word == ']':
                self.depth -= 1
            if word == '[':
                self.depth += 1
            if self.depth == 0:
                self.stack[-1] = ' '.join(self.stack[-1])
            else:
                if word in self.defs:
                    self.stack[-1].append(word)
                else:
                    self.stack[-1].append(word)
        elif ',' in word:
            *spl, name = word.split(',')
            for i in spl:
                if i != '':
                    self.run(i)
            self.defs[name] = str(self.stack.pop())
        elif word == '[':
            self.stack.append([])
            self.depth += 1
        elif word == ']':
            raise Exception('unexpected `]`')
        elif word[0] == '#':
            if self.depth == math.inf:
                self.dpeth = 0
            else:
                self.depth = math.inf
        elif word[0] == '\'':
            self.stack.append(word[1:])
        elif word[0].isdigit() or word[0] == '.':
            if '.' in word:
                self.stack.append(float(word))
            else:
                self.stack.append(int(word))
        elif word == 'id':
            pass
        elif word == 'inc' or word == '+1':
            a = self.stack.pop()
            self.stack.append(a + 1)
        elif word == 'dec' or word == '-1':
            a = self.stack.pop()
            self.stack.append(a - 1)
        elif word == 'cat' or word == '~':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(str(b) + ' ' + str(a))
        elif word == 'not' or word == '!':
            a = self.stack.pop()
            self.stack.append(not a)
        elif word == 'xnor':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append((not a) == (not b))
        elif word == 'nor':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append((not b) or (not a))
        elif word == 'nand':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(not (a and b))
        elif word == 'xor':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append((not a) != (not b))
        elif word == 'or' or word == '||' or word == '|':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b or a)
        elif word == 'and' or word == '&&' or word == '&':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b and a)
        elif word == 'lt' or word == '=' or word == '==':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b < a)
        elif word == 'ne' or word == 'neq' or word == '!=' or word == '~=':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b > a)
        elif word == 'lt' or word == '<':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b < a)
        elif word == 'gt' or word == '>':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b > a)
        elif word == 'le' or word == 'lte' or word == '<=':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b <= a)
        elif word == 'ge' or word == 'gte' or word == '>=':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b >= a)
        elif word == 'add' or word == '+':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b + a)
        elif word == 'sub' or word == '-':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b - a)
        elif word == 'mul' or word == '*':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b * a)
        elif word == 'div' or word == '/':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b / a)
        elif word == 'mod' or word == '%':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b % a)
        elif word == 'pow' or word == '^':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(b ** a)
        elif word == 'do':
            f = self.stack.pop()
            for thing in f.split(' '):
                self.run(thing)
        elif word == 'if':
            c = self.stack.pop()
            f = self.stack.pop()
            t = self.stack.pop()
            for thing in (t if c else f).split(' '):
                self.run(thing)
        elif word == 'select':
            c = self.stack.pop()
            f = self.stack.pop()
            t = self.stack.pop()
            self.stack.append(t if c else f)
        elif word == 'when':
            c = self.stack.pop()
            t = self.stack.pop()
            if c:
                for thing in t.split(' '):
                    self.run(thing)
        elif word == 'swap':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(a)
            self.stack.append(b)
        elif word == 'pop':
            self.stack.pop()
        elif word == 'dup':
            v = self.stack.pop()
            self.stack.append(v)
            self.stack.append(v)
        elif word == 'get':
            n = self.stack.pop()
            self.append(self.defs[n])
        elif word == 'def' or word == 'set' or word == 'is' or word == '=':
            n = self.stack.pop()
            o = self.stack.pop()
            self.defs[n] = str(o)
        else:
            got = self.defs[word]
            for i in got.split(' '):
                self.run(i)

def run(env, node):
    if  hasattr(node, 'text') and (node.text == 'quo' or node.text == 'quote'):
        txt = ' '.join(str(i) for i in node.list if not isinstance(i, SelectorOption)).strip()
        node.value = txt
        return [txt]
    args = [run(env, i) for i in node.list if not isinstance(i, SelectorOption)]
    if not hasattr(node, 'text'):
        return []
    words = node.text.split(' ')
    env.stack = []
    node.value = ''
    env.args = []
    env.depth = 0
    for arg in args:
        env.args.extend(arg)
    env.stack.extend(env.args)
    for word in words:
        try:
            env.run(word)
        except Exception as e:
            node.value = str(e)
    if node.value == '':
        node.value = ' '.join(str(i) for i in env.stack)
    return env.stack