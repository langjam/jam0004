#!/usr/bin/env python3

import math
import argparse
import cv2
import numpy as np
from hands import FindHands
from node import Node, Selector
from v2math import *
from forth import run, env

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
        self.pt = None
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
        size = data['self'].size
        x = math.sin(data['angle']) * size * 3.25
        y = math.cos(data['angle']) * size * 3.25
        xy = [x, y]
        dpos = data['pos']
        res = v2add(xy, dpos)
        src = ''.join(self.src)
        self.src = []
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
        if pt is not None:
            if self.pt is None:
                    self.handle1(pt)
            else:
                substeps = v2dist(self.pt, pt) * 2
                for i in range(int(substeps)):
                    self.handle1(v2lerp(self.pt, pt, i/substeps))
        self.pt = pt
        run(self.node)
        self.node.draw(self.img)

    def on_key(self, key):
        if key != -1:
            if len(self.selected) == 1:
                if chr(key) == '\r':
                    name = ''.join(self.src)
                    self.src = []
                    env.defs[name] = str(self.selected[0]).strip()
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
                self.node.add(self.make_node([150, size[0]//2], 50, ''))
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
    h.loop()

if __name__ == '__main__':
    main()