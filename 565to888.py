#!/usr/bin/env python

import sys

while 1:
	colour = sys.stdin.read(2)
	if not colour:
		break
	colour = ord(colour[1]) << 8 | ord(colour[0])

	r = (colour & 0xF800) >> 11
	g = (colour & 0x07E0) >> 5
	b = (colour & 0x001F) >> 0

	r *= 8
	g *= 4
	b *= 8

	sys.stdout.write(chr(r))
	sys.stdout.write(chr(g))
	sys.stdout.write(chr(b))
