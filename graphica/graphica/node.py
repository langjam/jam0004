import cv2
import colorsys
from graphica.v2math import *

phi = (5 ** 0.5 + 1) / 2


n = 0

class Node:
    def __init__(self, *args):
        if len(args) >= 2:
            self.pos = args[0]
            self.size = args[1]
        else:
            self.pos = [0, 0]
            self.size = 0
        self.color = [127, 127, 127]
        self.state = 'out'
        self.list = []
        self.root = False
        self.config = None 

    def __str__(self):
        return ' '.join(str(i) for i in self.list)

    def on_removed(self):
        for i in self.list:
            i.on_removed()

    def remove(self, pos):
        next = []
        for i in self.list:
            if i.pos != pos:
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
        font_size = self.config('font-size', default=0.5)
        font_weight = self.config('font-weight', default=1)
        if not self.root:
            for lno, l in enumerate(self.list):
                cv2.line(
                    img,
                    [int(i) for i in self.pos],
                    [int(i) for i in l.pos],
                    tuple((i*3+256)//4 for i in l.color[::-1]),
                    16
                )
                start = self.config('index-label', default=0.5)
                if len([i for i in self.list if not isinstance(i, SelectorOption)]) != 1:
                    size = cv2.getTextSize(str(lno+1), cv2.FONT_HERSHEY_SIMPLEX, font_size, font_weight)[0]
                    cv2.putText(
                        img,
                        str(lno+1),
                        [int(self.pos[0]*start + l.pos[0]*(1-start) - size[0]/3), int(self.pos[1]*start + l.pos[1]*(1-start) + size[1]/4)],
                        cv2.FONT_HERSHEY_SIMPLEX,
                        font_size,
                        (0, 0, 0),
                        font_weight,
                        cv2.LINE_AA
                    )
        if self.size > 0:
            if self.text != '':
                size = self.size
            else:
                # size = 8
                size = self.size
            cv2.circle(
                img,
                [int(i) for i in self.pos],
                int(size),
                (int(self.color[2]), int(self.color[1]), int(self.color[0])),
                cv2.FILLED
            )
        self.body(img)
        for l in self.list:
            l.config = self.config
            l.draw(img)

    def body(self, img):
        font_size = self.config('font-size', default=0.5)
        font_weight = self.config('font-weight', default=1)
        if hasattr(self, 'text'):
            size = cv2.getTextSize(self.text, cv2.FONT_HERSHEY_SIMPLEX, font_size, font_weight)[0]
            cv2.putText(
                img,
                self.text,
                [int(self.pos[0] - size[0]/2), int(self.pos[1] + size[1]/4)],
                cv2.FONT_HERSHEY_SIMPLEX,
                font_size,
                (0, 0, 0),
                font_weight,
                cv2.LINE_AA
            )
        if hasattr(self, 'value'):
            size = cv2.getTextSize(self.value, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)[0]
            cv2.putText(
                img,
                self.value,
                [int(self.pos[0] - size[0]/2), int(self.pos[1] + size[1] + self.size)],
                cv2.FONT_HERSHEY_SIMPLEX,
                font_size,
                (0, 0, 0),
                font_weight,
                cv2.LINE_AA
            )

    def add(self, e):
        e.conifg = self.config
        self.list.append(e)


class Selector(Node):
    def __init__(self, *init):
        global n
        n += phi
        self.text = init[-1]
        self.into = None
        Node.__init__(self, *init[:-1])
        self.then = lambda obj: None
        c = colorsys.hls_to_rgb(n % 1, 0.65, 0.1)
        self.color = [int(i * 255) for i in c]
    
    def __str__(self):
        names = []
        if self.text == 'quote' or self.text == 'quo':
            names.append('[')
        names.extend(str(i) for i in self.list)
        if self.text == 'quote' or self.text == 'quo':
            names.append(']')
        else:
            names.append(self.text)
        return ' '.join(names)

    def make_cb(self, n, angle):
        def ret(hit):
            next = []
            for l in self.list:
                if not isinstance(l, SelectorOption):
                    next.append(l)
            self.list = next
            return self.then({
                'name': n,
                'hit': hit,
                'angle': angle,
                'self': self,
            })
        return ret

    def enter(self, pos):
        option_offset = self.config('opt-offset', 1)
        self.oldcolor = self.color
        self.color = tuple((i + 255) / 2 for i in self.color)
        [x, y] = v2sub(pos, self.pos)
        angle = math.atan2(y, x)
        angle = math.degrees(angle)
        angle = round(angle/60)*60
        angle = math.radians(angle)
        for (v, c, n) in [
                (-60, (64, 255, 64), 'add'),
                (60, (255, 64, 64), 'del'),
        ]:
            x = math.cos(angle + math.pi + math.radians(v)) * self.size * option_offset + self.pos[0]
            y = math.sin(angle + math.pi + math.radians(v)) * self.size * option_offset + self.pos[1]
            case = SelectorOption([x, y], self.size / 2, n, self.make_cb(n, angle + math.pi))
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

    def enter(self, pos):
        self.cb(pos)
