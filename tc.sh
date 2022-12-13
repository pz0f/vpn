#!/bin/bash

modprobe sch_htb

tc qdisc del dev eth0 root
tc qdisc add dev eth0 root handle 1:0 htb default 1
tc class add dev eth0 parent 1:0 classid 1:1 htb rate $LIMIT ceil $LIMIT