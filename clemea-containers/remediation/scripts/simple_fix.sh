#!/bin/bash

# Simple network fix script for Rome and London
# Dependency: sshpass (sudo apt-get install sshpass)

ADMIN_USER="cisco"
ADMIN_PASS="cisco123"
ROME_IP="172.20.6.109"
LONDON_IP="172.20.6.108"

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass could not be found. Please install it with 'apt-get install sshpass' or similar."
    exit 1
fi

echo "--- Configuring Rome ($ROME_IP) ---"
sshpass -p "$ADMIN_PASS" ssh -o StrictHostKeyChecking=no "$ADMIN_USER@$ROME_IP" "
    echo 'Setting up eth1...'
    sudo ip link set eth1 up || true
    sudo ip addr flush dev eth1 || true
    sudo ip addr add 10.107.1.2/24 dev eth1 || true
    sudo ip addr add fc00:0:107:1::2/64 dev eth1 || true
    
    echo 'Adding routes...'
    sudo ip route add 10.0.0.0/8 via 10.107.1.1 dev eth1 || true
    sudo ip route add 10.1.1.0/24 via 10.107.1.1 dev eth1 || true
    sudo ip route add 10.8.0.0/16 via 10.107.1.1 dev eth1 || true
    sudo ip -6 route add fc00:0::/32 via fc00:0:107:1::1 dev eth1 || true
    sudo ip -6 route add fc00:0:101:1::/64 via fc00:0:107:1::1 dev eth1 || true
"

echo "--- Configuring London ($LONDON_IP) ---"
sshpass -p "$ADMIN_PASS" ssh -o StrictHostKeyChecking=no "$ADMIN_USER@$LONDON_IP" "
    echo 'Setting up eth1...'
    sudo ip link set eth1 up || true
    sudo ip addr flush dev eth1 || true
    sudo ip addr add 10.101.1.2/24 dev eth1 || true
    sudo ip addr add fc00:0:101:1::2/64 dev eth1 || true
    
    echo 'Adding routes...'
    sudo ip route add 10.0.0.0/24 via 10.101.1.1 dev eth1 || true
    sudo ip route add 10.107.1.0/24 via 10.101.1.1 dev eth1 || true
    sudo ip route add 10.1.1.0/24 via 10.101.1.1 dev eth1 || true
    sudo ip route add 40.0.0.0/24 via 10.101.1.1 dev eth1 || true
    sudo ip route add 50.0.0.0/24 via 10.101.1.1 dev eth1 || true
    sudo ip -6 route add fc00:0::/32 via fc00:0:101:1::1 dev eth1 || true
    sudo ip -6 route add fc00:0:40::1/64 via fc00:0:101:1::1 dev eth1 || true
    sudo ip -6 route add fc00:0:50::1/64 via fc00:0:101:1::1 dev eth1 || true
"

echo "Done."
