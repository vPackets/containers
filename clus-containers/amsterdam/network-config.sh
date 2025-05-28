#!/bin/sh 

# Amsterdam eth1 - global table
echo "Setting up Amsterdam eth1 ip addresses and routes"
ip addr add 10.101.1.2/24 dev eth1
ip addr add fc00:0:101:1::2/64 dev eth1
ip route add 10.107.1.0/24 via 10.101.1.1 dev eth1
ip route add 20.0.0.0/24 via 10.101.1.1 dev eth1
ip route add 30.0.0.0/24 via 10.101.1.1 dev eth1
ip -6 route add fc00:0000::/32 via fc00:0:101:1::1 dev eth1


# Amsterdam eth2 - vrf carrots
echo "Setting up Amsterdam eth2 ip addresses and routes"
ip addr add 10.101.2.2/24 dev eth2
ip addr add fc00:0:101:2::2/64 dev eth2
ip route add 10.107.2.0/24 via 10.101.2.1
ip route add 10.200.0.0/16 via 10.101.2.1 
ip route add 40.0.0.0/24 via 10.101.2.1
ip route add 50.0.0.0/24 via 10.101.2.1
ip -6 route add fc00:0000:40::/64 via fc00:0:101:2::1 dev eth2
ip -6 route add fc00:0000:50::/64 via fc00:0:101:2::1 dev eth2


echo "[DONE] Interface configuration complete."

