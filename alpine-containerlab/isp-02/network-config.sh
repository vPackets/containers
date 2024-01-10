#!/bin/sh 


ip addr add 203.0.113.100/24 dev eth1
ip link set eth1 up
ip route add 192.0.2.0/24 via 203.0.113.1 dev eth1