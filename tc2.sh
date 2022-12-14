#!/bin/bash

modprobe sch_sfq

tc qdisc delete dev $IF root

tc qdisc add dev $IF root handle 1: prio
tc filter add dev $IF parent 1: protocol ip handle 6 fw flowid 1:

tc qdisc add dev $IF parent 1:1 handle 101: sfq perturb 20 flows 3000 limit 3000 depth 3000
tc filter add dev $IF parent 101: protocol ip handle 10 flow hash keys mark,dst divisor 1024

iptables -t mangle -F
iptables -t mangle -A PREROUTING -j MARK --set-mark 6
