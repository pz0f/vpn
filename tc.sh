#!/bin/bash
# usage: sudo IF=eth0 IF2=$(ip -br -4 a sh | grep 172.18.0.1 | awk '{print $1}') DOWNLOAD_LIMIT=500kbps UPLOAD_LIMIT=500kbps ./tc.sh

modprobe sch_htb
modprobe sch_sfq

tc qdisc delete dev $IF root

tc qdisc add dev $IF root handle 1: htb default 12
tc class add dev $IF classid 1:1 htb rate $UPLOAD_LIMIT ceil $UPLOAD_LIMIT
tc filter add dev $IF parent 1: protocol ip handle 6 fw flowid 1:1

tc qdisc add dev $IF parent 1:1 handle 101: sfq perturb 20 flows 3000 limit 3000 depth 3000
tc filter add dev $IF parent 101: protocol ip handle 10 flow hash keys dst divisor 1024

tc qdisc delete dev $IF2 root

tc qdisc add dev $IF2 root handle 1: htb default 12
tc class add dev $IF2 classid 1:1 htb rate $DOWNLOAD_LIMIT ceil $DOWNLOAD_LIMIT
tc filter add dev $IF2 parent 1: protocol ip handle 6 fw flowid 1:1

tc qdisc add dev $IF2 parent 1:1 handle 101: sfq perturb 20 flows 3000 limit 3000 depth 3000
tc filter add dev $IF2 parent 101: protocol ip handle 10 flow hash keys src divisor 1024

iptables -t mangle -F
iptables -t mangle -X

iptables -t mangle -N CONNMARK1
iptables -t mangle -A CONNMARK1 -j MARK --set-mark 6
iptables -t mangle -A CONNMARK1 -j CONNMARK --save-mark

iptables -t mangle -A POSTROUTING -o $IF -s 172.0.0.0/8 ! -p tcp -j MARK --set-mark 6
iptables -t mangle -A POSTROUTING -o $IF -s 172.0.0.0/8 -p tcp -m conntrack --ctstate ESTABLISHED,RELATED -j CONNMARK --restore-mark

iptables -t mangle -A POSTROUTING ! -s 172.0.0.0/8 -d 172.0.0.0/8 ! -p tcp -j MARK --set-mark 6
iptables -t mangle -A POSTROUTING ! -s 172.0.0.0/8 -d 172.0.0.0/8 -p tcp -m conntrack --ctstate ESTABLISHED,RELATED -j CONNMARK --restore-mark
iptables -t mangle -A POSTROUTING ! -s 172.0.0.0/8 -d 172.0.0.0/8 -p tcp -m conntrack --ctstate NEW -j CONNMARK1
