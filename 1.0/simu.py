#! /usr/bin/python
from TOSSIM import *
import sys

import os

logDir = "log"
if not os.path.exists(logDir):
    os.makedirs(logDir)

stream = {
    "Boot": sys.stdout,
    "Radio": sys.stdout,
    "Led": sys.stdout,
    "RadioSend": open(logDir + "/send.log", "w"),
    "RadioRec": open(logDir + "/rec.log", "w"),
    "Pkg": open(logDir + "/pkg.log", "w")
}


t = Tossim([])
r = t.radio()

f = open("topo.txt", "r")
for line in f:
    s = line.split()
    if s:
        print " ", s[0], " ", s[1], " ", s[2];
        r.add(int(s[0]), int(s[1]), float(s[2]))

for key, value in stream.items():
    t.addChannel(key, value);


time_boot = 0*t.ticksPerSecond();

for i in range(1, 4):
    node = t.getNode(i)
    print "Creating node ", i, "..."
    node.bootAtTime(time_boot + i * 5)


#Add noise to the medium channel
noise = open("meyer-heavy.txt", "r")
for line in noise:
    str1 = line.strip()
    if str1:
        val = int(str1)
        for i in range(1, 4):
            t.getNode(i).addNoiseTraceReading(val)

for i in range(1, 4):
    print "Creating noise model for ",i;
    t.getNode(i).createNoiseModel()


# Simulation time is set to 9999
for i in range(1099):
    t.runNextEvent()

for _, out in stream.items():
    if out != sys.stdout:
        out.close()
