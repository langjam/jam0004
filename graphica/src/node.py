import random
import cv2
from v2math import *

class Node:
    def __init__(self, *args):
        if len(args) >= 2:
            self.pos = args[0]
            self.size = args[1]
        else:
            self.pos = [0, 0]
            self.size = 0
        self.max_size = 256
        self.min_size = 50
        self.color = tuple(i + random.randrange(0, 48) for i in [127, 127, 127])
        self.state = 'out'
        self.list = []
        self.root = False

    def __str__(self):
        return ' '.join(str(i) for i in self.list)

    def on_removed(self):
        for i in self.list:
            i.on_removed()

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
        if hasattr(self, 'text'):
            size = cv2.getTextSize(self.text, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)[0]
            self.size = int(min(self.max_size, max(max(size) * 0.5 + 10, self.min_size)))
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
                [int(self.pos[0] - size[0]/2), int(self.pos[1] + size[1]/4)],
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (0, 0, 0),
                1,
                cv2.LINE_AA
            )
        if hasattr(self, 'value'):
            size = cv2.getTextSize(self.value, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)[0]
            cv2.putText(
                img,
                self.value,
                [int(self.pos[0] - size[0]/2), int(self.pos[1] + size[1] + self.size)],
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
        names = []
        names.extend(str(i) for i in self.list)
        names.append(self.text)
        return ' '.join(names)

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
            x = math.sin(angle + math.pi * v) * self.size * 1.25 + self.pos[0]
            y = math.cos(angle + math.pi * v) * self.size * 1.25 + self.pos[1]
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
        for i in self.list:
            i.on_removed()

class SelectorOption(Node):
    def __init__(self, *args):
        self.text = args[-2]
        self.cb = args[-1]
        Node.__init__(self, *args[:-2])
        self.color = (255, 0, 0)
        self.max_size = self.size
        self.min_size = self.size

    def enter(self, pos):
        self.cb(pos)
