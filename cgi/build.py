#!/usr/bin/env python2.7

import os
import sys
import commands

CWD = os.path.abspath(os.path.dirname(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(CWD, '..', '..'))
LOGS = os.path.join(PROJECT_DIR, 'logs.txt')
NIKOLA_BIN = os.path.join(PROJECT_DIR, 'nikola')

print 'Content-Type: text/plain'
print

os.chdir(PROJECT_DIR)

cmd = NIKOLA_BIN + ' build'

output = []
try:
    status, output = commands.getstatusoutput(cmd)
except Exception as e:
    sys.exit()

try:
    with open(LOGS, 'w') as fp:
        fp.write("".join(output))
except Exception as e:
    pass

print 'OK'
