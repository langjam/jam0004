
import math
import json
import pathlib
import configparser
import cv2
import numpy as np
from graphica.node import Node, Selector
from graphica.v2math import *
from graphica.forth import run, Env
import graphica.save as save

class Handler:
    def __init__(self, one_hand=True):
        parser = configparser.ConfigParser()
        parser.read(pathlib.Path(__file__).parent / 'graphica.ini')
        self.ini_force = parser['force'] if 'force' in parser.sections() else {}
        self.ini_vars = parser['vars'] if 'vars' in parser.sections() else {}
        def mouse_cb(who_cares, x, y, *who_cares_two_electic_boogaloo):
            self.mouse_xy = [x, y]
        self.window_name = cv2.namedWindow('Graphica')
        cv2.setMouseCallback('Graphica', mouse_cb)
        self.one_hand = one_hand
        self.img = None
        self.node = Node()
        self.node.config = self.config
        self.node.root = True
        self.pt = None
        self.src = []
        self.selected = []
        self.mouse_xy = None
        self.env = Env()
        for key in self.ini_vars:
            self.env.defs[key] = self.override[key]
        if one_hand:
            self.cap = cv2.VideoCapture(0)
            if "FindHands" not in globals():
                from graphica.hands import FindHands
                globals()["FindHands"] = FindHands
                self.hands = FindHands()
            else:
                self.hands = globals()["FindHands"]()
        self.save_file = pathlib.Path(__file__).parent.parent / "saves/save.json"
        try:
            with open(self.save_file) as save:
                self.full_load(save.read())
        except IOError as ioe:
            print(ioe)
        except json.JSONDecodeError as jse:
            print(jse)

    def config(self, var, default=None):
        if var in self.ini_force:
            return type(default)(self.override[var])
        elif var in self.env.defs:
            return type(default)(self.env.defs[var])
        else:
            return default

    def data_load(self, src):
        self.env.defs = json.loads(src)
        for key in self.ini_vars:
            self.env.defs[key] = self.override[key]

    def code_loads(self, src):
        self.node = save.load_post(self, json.loads(src))
        self.node.root = True

    def data_save(self):
        return json.dumps(self.env.defs)

    def code_save(self):
        return json.dumps(save.save_pre(self.node))

    def full_load(self, src):
        data = json.loads(src)
        self.env.defs = data['env']
        self.node = save.load_post(self, data['node'])
        self.node.root = True
        
    def full_save(self):
        return json.dumps({
            "node": save.save_pre(self.node),
            "env": self.env.defs,
        })

    def make_node(self, pos, size, name):
        ret = Selector(pos, size, name)
        ret.then = self.then
        ret.into = self.selected
        ret.config = self.config
        return ret

    def then(self, data):
        if data['name'] == 'add':
            self.node_on_add(data)
        if data['name'] == 'del':
            self.node_remove(data)

    def node_on_add(self, data):
        size = data['self'].size
        angle = data['angle']
        x = math.cos(angle) * (size * 2.5)
        y = math.sin(angle) * (size * 2.5)
        xy = [x, y]
        dpos = data['self'].pos
        res = v2add(xy, dpos)
        src = ''.join(self.src)
        self.src = []
        data['self'].add(self.make_node(res, 65, src))

    def node_remove(self, data):
        self.node.remove(data['self'].pos)
        
    def get(self, *n):
        if self.one_hand:
            return self.hands.getPosition(self.img, n)
        elif self.mouse_xy is not None:
            return [self.mouse_xy]
        else:
            return []
            
    def handle1(self, pt):
        self.node.each(pt)

    def handle(self, pt):
        if pt is not None:
            if self.pt is None:
                    self.handle1(pt)
            else:
                substeps = v2dist(self.pt, pt) * 2
                for i in range(int(substeps)):
                    self.handle1(v2lerp(self.pt, pt, i/substeps))
        self.pt = pt
        self.node.draw(self.img)

    def on_key(self, key):
        if key != -1:
            if len(self.selected) == 1:
                if chr(key) == '\r':
                    name = ''.join(self.src)
                    self.src = []
                    self.env.defs[name] = str(self.selected[0]).strip()
                    self.selected[0].text = name
                    self.selected[0].list[:] = []
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
        last_state = None
        while True:
            if self.one_hand:
                succeed, ximg = self.cap.read()
            else:
                ximg = np.zeros((720, 1280, 4), dtype=np.uint8)
                ximg.fill(255)
            mode = self.config('mode', default='light')
            if mode == 'dark':
                ximg = ~ximg
            self.img = cv2.flip(ximg, 1)
            pt = self.get(8)
            if len(self.node.list) == 0:
                size = self.img.shape[:2]
                self.node.add(self.make_node([200, size[0]//2], 65, 'id'))
            if len(pt) == 1:
                self.handle(pt[0])
            else:
                self.handle(self.pt)
            next_state = self.code_save()
            if next_state != last_state:
                run(self.env, self.node)
                with open(self.save_file, "w") as save:
                    save.write(self.full_save())
                last_state = next_state
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
            if mode == 'dark':
                self.img = ~self.img
            cv2.imshow('Graphica', self.img)
            key = cv2.waitKey(1)
            if key == 27:
                break
            self.on_key(key)
            n += 1

    def dist(self, a, b):
        va = self.get(a)
        vb = self.get(b)
        if len(va) > 0 and len(vb) > 0:
            va = va[0]
            vb = vb[0]
            return v2dist(va, vb)
        return math.nan
