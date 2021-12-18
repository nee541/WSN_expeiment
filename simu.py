#! /usr/bin/python
import sys
from TOSSIM import *

tossim = Tossim([])
radio = tossim.radio()

nodes = set()

fLog = open("simu.log", "w")
# tossim.addChannel("Boot", sys.stdout)
# tossim.addChannel("Sender", sys.stdout)
tossim.addChannel("Receiver", sys.stdout)
              
with open("topo.txt", "r") as fTopo:
    for line in fTopo.readlines():
        topo = line.split()
        if topo:
            print topo
            try:
                nodeFrom = int(topo[0])
                nodeTo = int(topo[0])
                nodes.add(nodeFrom)
                nodes.add(nodeTo)
                radio.add(nodeFrom, nodeTo, float(topo[2]))                         
            except ValueError:
                print "line format error in", line

with open("meyer-heavy.txt", "r") as fNoise:
    for line in fNoise.readlines():
        sVal = line.strip()
        if sVal:
            val = int(sVal)
            for node in nodes:
                tossim.getNode(node).addNoiseTraceReading(val)

for node in nodes:
    print "Creating noise model for ", node
    tossim.getNode(node).createNoiseModel()


tossim.getNode(1).bootAtTime(100001)
tossim.getNode(2).bootAtTime(800008)
tossim.getNode(3).bootAtTime(2000000)

for _ in range(1000):
    tossim.runNextEvent()
