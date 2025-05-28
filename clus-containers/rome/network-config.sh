#!/bin/sh 

# Rome eth1 - global table
echo "Setting up Rome eth1 ip addresses and routes"
ip addr add 10.107.1.2/24 dev eth1
ip addr add fc00:0:107:1::2/64 dev eth1
ip route add 10.101.1.0/24 via 10.107.1.1 dev eth1
ip -6 route add fc00:0000::/32 via fc00:0:107:1::1 dev eth1



# Rome eth2 - vrf carrots
echo "Setting up Rome eth2 ip addresses and routes"
ip addr add 10.107.2.2/24 dev eth2
ip addr add fc00:0:107:2::2/64 dev eth2
ip route add 10.101.2.0/24 via 10.107.2.1 dev eth2
ip route add 10.200.0.0/24 via 10.107.2.1 dev eth2
ip -6 route add fc00:0000:101:2::/64 via fc00:0:107:2::1 dev eth2



# Rome loopback interface
echo "Setting up Rome loopback ip addresses"
ip addr add 20.0.0.1/24 dev lo
ip addr add fc00:0:20::1/64 dev lo
ip addr add 30.0.0.1/24 dev lo
ip addr add fc00:0:30::1/64 dev lo
ip addr add 40.0.0.1/24 dev lo
ip addr add fc00:0:40::1/64 dev lo
ip addr add 50.0.0.1/24 dev lo
ip addr add fc00:0:50::1/64 dev lo


