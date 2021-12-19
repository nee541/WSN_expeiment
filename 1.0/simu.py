#! /usr/bin/python
from TOSSIM import *
import sys

out = sys.stdout

# Number of nodes in the simulated network is 3
number_of_nodes = 4

t = Tossim([])
m = t.mac()
r = t.radio()

#Open a topology file and parse the data, where first linebreak is transmitter nodeID, second is receiver nodeID and third is dBm value
f = open("topo.txt", "r")
for line in f:
    s = line.split()
    if s:
        print " ", s[0], " ", s[1], " ", s[2];
        r.add(int(s[0]), int(s[1]), float(s[2]))

# The type of debug messages that will be printed out. [add, comment and uncomment as you need]
t.addChannel("Init",out)
t.addChannel("Boot", out);
t.addChannel("Radio", out);
t.addChannel("Role",out);
t.addChannel("Led", out);
t.addChannel("RadioSend", out);
t.addChannel("RadioRec", out);
t.addChannel("Pkg", out);
#t.addChannel("Drop", sys.stdout);
#t.addChannel("Fwd", sys.stdout);
#t.addChannel("BASE", sys.stdout);
#t.addChannel("DBG", sys.stdout);
#t.addChannel("ERR", sys.stdout);
#t.addChannel("FILE", sys.stdout);

#Boot Nodes

time_boot = 0*t.ticksPerSecond();

print("Creating node 1...");
node1 = t.getNode(1);
#time1 = 0*t.ticksPerSecond();
node1.bootAtTime(time_boot);


print("Creating node 2...");
node2 = t.getNode(2);
#time1 = 0*t.ticksPerSecond();
node2.bootAtTime(time_boot + 10);

print("Creating node 3...");
node3 = t.getNode(3);
#time1 = 0*t.ticksPerSecond();
node3.bootAtTime(time_boot + 15);

#Add noise to the medium channel
noise = open("meyer-heavy.txt", "r")
for line in noise:
    str1 = line.strip()
    if str1:
        val = int(str1)
        for i in range(number_of_nodes):
            t.getNode(i).addNoiseTraceReading(val)

for i in range(1,4):
    print "Creating noise model for ",i;
    t.getNode(i).createNoiseModel()


# Simulation time is set to 9999
for i in range(1099):
    t.runNextEvent()
