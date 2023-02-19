#!/usr/bin/env python3

from graphica.handler import Handler

def main():
    h = Handler(one_hand=False)
    h.loop()

if __name__ == '__main__':
    main()