from node import SelectorOption

import math

class Env:
    def __init__(self):
        self.stack = []
        self.defs = dict()

    def run(self, word):
        if word == '' or word == 'root':
            pass
        elif (word[0] == ',' and ',' in word[1:]) or (word[0] != ',' and ',' in word):
            *spl, name = word.split(',')
            for i in spl:
                self.run(i)
            self.defs[name] = [self.stack.pop()]
        elif self.depth != 0:
            if word == ']':
                self.depth -= 1
            if word == '[':
                self.depth += 1
            if self.depth != 0:
                if word in self.defs:
                    self.stack[-1].extend(self.defs[word])
                else:
                    self.stack[-1].append(word)
        elif word == '[':
            self.stack.append([])
            self.depth += 1
        elif word == ']':
            raise Exception("unexpected `]`")
        elif word[0] == '#':
            if self.depth == math.inf:
                self.dpeth = 0
            else:
                self.depth = math.inf
        elif word[0] == ',':
            self.stack.append(word[1:])
        elif word[0].isdigit() or word[0] == '.':
            if '.' in word:
                self.stack.append(float(word))
            else:
                self.stack.append(int(word))
        elif word == 'inc' or word == '+1':
            a = self.stack.pop()
            self.stack.append(a + 1)
        elif word == 'dec' or word == '-1':
            a = self.stack.pop()
            self.stack.append(a - 1)
        elif word == 'cat' or word == '~':
            a = self.stack.pop()
            b = self.stack.pop()
            self.stack.append(str(b) + str(a))
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
        elif word == 'do':
            f = self.stack.pop()
            for thing in f:
                self.run(thing)
        elif word == 'exa':
            n = self.stack.pop()
            o = self.stack.pop()
            self.defs[n].extend(n)
        elif word == 'when':
            c = self.stack.pop()
            f = self.stack.pop()
            if c:
                for thing in f:
                    self.run(thing)
        elif word == 'ex':
            n = self.stack.pop()
            o = self.stack.pop()
            self.defs[n].append(n)
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
        elif word == 'fn' or word == 'fun':
            n = self.stack.pop()
            o = self.stack.pop()
            self.defs[n] = o
        elif word == 'def' or word == 'is' or word == '=':
            n = self.stack.pop()
            o = self.stack.pop()
            self.defs[n] = [o]
        else:
            if word not in self.defs:
                self.stack.append(0)
            else:
                got = self.defs[word]
                self.stack.extend(got)

env = Env()

def run(node):
    args = [run(i) for i in node.list if not isinstance(i, SelectorOption)]
    if not hasattr(node, 'text'):
        return []
    words = node.text.split(' ')
    env.stack = []
    node.value = ''
    env.args = []
    env.depth = 0
    for arg in args:
        env.args.extend(arg)
    if '?' not in words:
        env.stack.extend(env.args)
    for word in words:
        try:
            env.run(word)
        except Exception as e:
            node.value = str(e)
    if node.value == '':
        node.value = ' '.join(str(i) for i in env.stack)
    return env.stack