#!/bin/sh 


ip addr add 192.0.2.100/24 dev eth1
ip link set eth1 up
ip route add 203.0.113.0/24 via 192.0.2.1 dev eth1