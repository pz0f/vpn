#!/bin/bash

IF=eth0
LIMIT=500kbps

rm /etc/resolv.conf
echo nameserver 8.8.8.8 > /etc/resolv.conf

ntpdate time.nist.gov

modprobe sch_htb

tc qdisc del dev $IF root
tc qdisc add dev $IF root handle 1:0 htb default 1
tc class add dev $IF parent 1:0 classid 1:1 htb rate $LIMIT ceil $LIMIT
