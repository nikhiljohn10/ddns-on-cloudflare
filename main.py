#!/usr/bin/env python

import sys

from api import DDNS

def main(src):
	try:
		ddns = DDNS(src)
	except Exception as err:
		sys.exit('Error: %s' % (err))

if __name__ == '__main__':
	main(sys.argv[1])
