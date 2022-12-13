#!/bin/bash

modprobe sch_htb

tc qdisc del dev $IF root
tc qdisc add dev $IF root handle 1:0 htb default 1
tc class add dev $IF parent 1:0 classid 1:1 htb rate $LIMIT ceil $LIMIT