#!/usr/bin/env python3

import random
import cv2
import math
import numpy as np
from hands import FindHands

def lerp(a, b, t):
    return (1 - t) * a + t * b

def v2lerp(a, b, t):
    return [lerp(a[0], b[0], t), lerp(a[1], b[1], t)]

def v2dist(p1, p2):
    x = p1[0] - p2[0]
    y = p1[1] - p2[1]
    return math.sqrt(x*x + y*y)

def v2add(p1, p2):
    x = p1[0] + p2[0]
    y = p1[1] + p2[1]
    return [x, y]

def v2sub(p1, p2):
    x = p1[0] - p2[0]
    y = p1[1] - p2[1]
    return [x, y]

def v2mul(p1, p2):
    x = p1[0] * p2[0]
    y = p1[1] * p2[1]
    return [x, y]

def v2div(p1, p2):
    x = p1[0] / p2[0]
    y = p1[1] / p2[1]
    return [x, y]

class Node:
    def __init__(self, *args):
        if len(args) >= 2:
            self.pos = args[0]
            self.size = args[1]
        else:
            self.pos = [0, 0]
            self.size = 0
        self.color = tuple(i + random.randrange(0, 48) for i in [127, 127, 127])
        self.state = 'out'
        self.list = []
        self.root = False

    def __str__(self):
        return '\n'.join(str(i) for i in self.list)

    def on_removed(self):
        pass

    def remove(self, pos):
        next = []
        for i in self.list:
            if not i.has(pos):
                i.remove(pos)
                next.append(i)
            else:
                i.on_removed()
        self.list = next

    def has(self, pos):
        return v2dist(self.pos, pos) < self.size

    def each(self, pos):
        if self.has(pos):
            if self.state != 'in':
                self.enter(pos)
                self.state = 'in'
        else:
            if self.state != 'out':
                self.exit(pos)
                self.state = 'out'
        for l in self.list:
            l.each(pos)

    def enter(self, pos):
        pass

    def exit(self, pos):
        pass

    def draw(self, img):
        if not self.root:
            for l in self.list:
                cv2.line(
                    img,
                    [int(i) for i in self.pos],
                    [int(i) for i in l.pos],
                    (int(l.color[2]), int(l.color[1]), int(l.color[0])),
                    10
                )
        if self.size > 0:
            cv2.circle(
                img,
                [int(i) for i in self.pos],
                int(self.size),
                (int(self.color[2]), int(self.color[1]), int(self.color[0])),
                cv2.FILLED
            )
        self.body(img)
        for l in self.list:
            l.draw(img)

    def body(self, img):
        if hasattr(self, 'text'):
            size = cv2.getTextSize(self.text, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)[0]
            cv2.putText(
                img,
                self.text,
                [int(self.pos[0] - size[0]/2), int(self.pos[1])],
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (0, 0, 0),
                1,
                cv2.LINE_AA
            )

    def add(self, e):
        self.list.append(e)


class Selector(Node):
    def __init__(self, *init):
        self.text = init[-2]
        self.opts = init[-1]
        self.into = None
        Node.__init__(self, *init[:-2])
    
    def __str__(self):
        names = [self.text]
        names.extend(str(i) for i in self.list)
        return '(' + ' '.join(names) + ')'

    def make_cb(self, n, k):
        def ret(pos):
            next = []
            for l in self.list:
                if not isinstance(l, SelectorOption):
                    next.append(l)
            self.list = next
            return k({
                'name': n,
                'pos': pos,
                'angle': self.angle,
                'self': self,
            })
        return ret

    def enter(self, pos):
        self.oldcolor = self.color
        self.color = tuple((i + 255) / 2 for i in self.color)
        angle = math.atan2(*v2sub(pos, self.pos))
        self.angle = angle + math.pi
        for (v, c, n, k) in self.opts:
            x = math.sin(angle + math.pi * v) * self.size + self.pos[0]
            y = math.cos(angle + math.pi * v) * self.size + self.pos[1]
            case = SelectorOption([x, y], self.size / 2, n, self.make_cb(n, k))
            case.color = c
            self.add(case)
        if isinstance(self.into, list):
            self.into.append(self)

    def exit(self, pos):
        self.color = self.oldcolor
        next = []
        for l in self.list:
            if not isinstance(l, SelectorOption):
                next.append(l)
        if isinstance(self.into, list):
            self.into[:] = [i for i in self.into if i is not self]
        self.list = next

    def on_removed(self):
        if isinstance(self.into, list):
            self.into[:] = [i for i in self.into if i is not self]


class SelectorOption(Node):
    def __init__(self, *args):
        self.text = args[-2]
        self.cb = args[-1]
        Node.__init__(self, *args[:-2])
        self.color = (255, 0, 0)

    def enter(self, pos):
        self.cb(pos)


class Handler:
    def __init__(self, one_hand=True):
        def mouse_cb(who_cares, x, y, *who_cares_two_electic_boogaloo):
            self.mouse_xy = [x, y]
        self.window_name = cv2.namedWindow('Graphica')
        cv2.setMouseCallback('Graphica', mouse_cb)
        self.one_hand = one_hand
        self.img = None
        self.node = Node()
        self.node.root = True
        self.pt = [0, 0]
        self.src = []
        self.selected = []
        self.mouse_xy = [0, 0]
        if one_hand:
            self.cap = cv2.VideoCapture(0)
            self.hands = FindHands()

    def make_node(self, pos, size, name):
        options = [
                (0.7, (64, 255, 64), 'new', self.node_on_add),
                (1.3, (255, 64, 64), 'del', self.node_remove),
        ]
        ret = Selector(pos, size, name, options)
        ret.into = self.selected
        return ret

    def node_on_add(self, data):
        size = 50
        x = math.sin(data['angle']) * size * 2.5
        y = math.cos(data['angle']) * size * 2.5
        xy = [x, y]
        dpos = data['pos']
        res = v2add(xy, dpos)
        src = ''.join(self.src)
        self.src = []
        if src == 'root':
            self.node.add(self.make_node(res, 50, 'root'))
        elif src == '':
            data['self'].add(self.make_node(res, 50, 'do'))
        else:
            data['self'].add(self.make_node(res, 50, src))

    def node_remove(self, data):
        self.node.remove(data['pos'])
        
    def get(self, *n):
        if self.one_hand:
            return self.hands.getPosition(self.img, n)
        else:
            return [self.mouse_xy]
            
    def handle1(self, pt):
        self.node.each(pt)

    def handle(self, pt):
        substeps = v2dist(self.pt, pt) * 2
        for i in range(int(substeps)):
            self.handle1(v2lerp(self.pt, pt, i/substeps))
        self.pt = pt
        self.node.draw(self.img)

    def on_key(self, key):
        if key != -1:
            if len(self.selected) == 1:
                if chr(key) == '\r':
                    self.selected[0].text = ''.join(self.src)
                    self.src = []
                elif chr(key).isprintable():
                    self.selected[0].text += chr(key)
                elif key == 127:
                    if len(self.selected[0].text) != 0:
                        self.selected[0].text = self.selected[0].text[:-1]
                else:
                    print('key', key)
            else:
                if chr(key).isprintable():
                    self.src.append(chr(key))
                elif key == 127:
                    if len(self.src) != 0:
                        self.src.pop(-1)
                else:
                    print('key', key)

    def loop(self):
        n = 0
        while True:
            if self.one_hand:
                succeed, ximg = self.cap.read()
            else:
                ximg = np.zeros((720, 1280, 4), dtype=np.uint8)
                ximg.fill(255)
            self.img = cv2.flip(ximg, 1)
            pt = self.get(8)
            if len(self.node.list) == 0:
                size = self.img.shape[:2]
                self.node.add(self.make_node([150, size[0]//2], 50, 'root'))
            if len(pt) == 1:
                self.handle(pt[0])
            else:
                self.handle(self.pt)
            if self.pt is not None:
                cv2.circle(self.img, self.pt, 5, (0,255,0), cv2.FILLED)
            cv2.putText(
                self.img,
                ''.join(self.src),
                [10, 30],
                cv2.FONT_HERSHEY_SIMPLEX,
                1,
                (0, 0, 0),
                2,
                cv2.LINE_AA
            )
            cv2.imshow('Graphica', self.img)
            self.on_key(cv2.waitKey(1))
            n += 1

    def dist(self, a, b):
        va = self.get(a)
        vb = self.get(b)
        if len(va) > 0 and len(vb) > 0:
            va = va[0]
            vb = vb[0]
            return v2dist(va, vb)
        return math.nan

def main():
    h = Handler(one_hand=False)
    # h = Handler(one_hand=True)
    h.loop()

if __name__ == '__main__':
    main()