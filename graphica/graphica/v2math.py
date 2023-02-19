
import math

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
