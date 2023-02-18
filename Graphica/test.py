from hands import FindHands
import cv2
import math
import random

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

    def remove(self, pos):
        next = []
        for i in self.list:
            if not i.has(pos):
                i.remove(pos)
                next.append(i)
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
        if hasattr(self, "text"):
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
        Node.__init__(self, *init[:-2])

    def make_cb(self, k):
        def ret(pos):
            return k({
                "pos": pos,
                "angle": self.angle,
                "self": self,
            })
        return ret

    def enter(self, pos):
        self.oldcolor = self.color
        self.color = tuple((i + 255) / 2 for i in self.color)
        angle = math.atan2(*v2sub(pos, self.pos))
        self.angle = angle + math.pi
        for (v, c, k) in self.opts:
            x = math.sin(angle + math.pi * v) * self.size + self.pos[0]
            y = math.cos(angle + math.pi * v) * self.size + self.pos[1]
            case = SelectorOption([x, y], self.size / 2, self.make_cb(k))
            case.color = c
            self.add(case)

    def exit(self, pos):
        self.color = self.oldcolor
        next = []
        for l in self.list:
            if not isinstance(l, SelectorOption):
                next.append(l)
        self.list = next


class SelectorOption(Node):
    def __init__(self, *args):
        self.cb = args[-1]
        Node.__init__(self, *args[:-1])
        self.color = (255, 0, 0)

    def enter(self, pos):
        self.cb(pos)


class Handler:
    def __init__(self):
        self.cap = cv2.VideoCapture(0)
        self.hands = FindHands()
        self.img = None
        self.node = Node()
        self.node.root = True
        self.pt = [0, 0]
        self.mode = 'empty'

    def make_node(self, pos, size):
        options = [
                (0.75, (64, 255, 64), self.node_add),
                (1.25, (255, 64, 64), self.node_remove),
        ]
        if self.mode == 'empty':
            return Selector(pos, size, 'do', options)
        elif self.mode == 'add':
            Selector(pos, size, 'add', options)
        else:
            return Selector(pos, size, '?', options)

    def node_add(self, data):
        size = 50
        x = math.sin(data["angle"]) * size * 2.5
        y = math.cos(data["angle"]) * size * 2.5
        xy = [x, y]
        dpos = data["pos"]
        res = v2add(xy, dpos)
        data["self"].add(self.make_node(res, size))

    def node_remove(self, data):
        self.node.remove(data["pos"])
        
    def get(self, *n):
        return self.hands.getPosition(self.img, n)

    def handle1(self, pt):
        self.node.each(pt)

    def handle(self, pt):
        substeps = v2dist(self.pt, pt) * 2
        for i in range(int(substeps)):
            self.handle1(v2lerp(self.pt, pt, i/substeps))
        self.pt = pt
        self.node.draw(self.img)

    def loop(self):
        n = 0
        while True:
            succeed, ximg = self.cap.read()
            self.img = cv2.flip(ximg, 1)
            pt = self.get(8)
            if len(self.node.list) == 0:
                size = self.img.shape[:2]
                print(size)
                self.mode = 'empty'
                self.node.add(self.make_node([size[1]//2, size[0]//2], 50))
            if len(pt) == 1:
                self.handle(pt[0])
            else:
                self.handle(self.pt)
            if self.pt is not None:
                cv2.circle(self.img, self.pt, 5, (0,255,0), cv2.FILLED)
            cv2.imshow("Graphica", self.img)
            if cv2.waitKey(1) == ord("q"):
                break
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
    h = Handler()
    h.loop()

if __name__ == '__main__':
    main()