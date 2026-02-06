#!/bin/bash

# Network fix script using 'expect' for password automation
# Useful if sshpass is not installed.
# Requires 'expect' package (usually available or installable via `apt-get install expect`)

ADMIN_USER="cisco"
ADMIN_PASS="cisco123"
ROME_IP="172.20.6.109"
LONDON_IP="172.20.6.108"

# Function to run commands on a host via expect
run_remote() {
    local HOST=$1
    local CMDS=$2
    
    echo "--- Connecting to $HOST ---"
    
    expect -c "
        set timeout 10
        spawn ssh -o StrictHostKeyChecking=no $ADMIN_USER@$HOST \"$CMDS\"
        expect {
            \"password:\" {
                send \"$ADMIN_PASS\r\"
                exp_continue
            }
            eof
        }
    "
}

# Define commands for Rome
ROME_CMDS="
echo 'Configuring Rome eth1...'
sudo ip link set eth1 up || true
sudo ip addr flush dev eth1 || true
sudo ip addr add 10.107.1.2/24 dev eth1 || true
sudo ip addr add fc00:0:107:1::2/64 dev eth1 || true

echo 'Adding Routes...'
sudo ip route add 10.0.0.0/8 via 10.107.1.1 dev eth1 || true
sudo ip route add 10.1.1.0/24 via 10.107.1.1 dev eth1 || true
sudo ip route add 10.8.0.0/16 via 10.107.1.1 dev eth1 || true
sudo ip -6 route add fc00:0::/32 via fc00:0:107:1::1 dev eth1 || true
sudo ip -6 route add fc00:0:101:1::/64 via fc00:0:107:1::1 dev eth1 || true
"

# Define commands for London
LONDON_CMDS="
echo 'Configuring London eth1...'
sudo ip link set eth1 up || true
sudo ip addr flush dev eth1 || true
sudo ip addr add 10.101.1.2/24 dev eth1 || true
sudo ip addr add fc00:0:101:1::2/64 dev eth1 || true

echo 'Adding Routes...'
sudo ip route add 10.0.0.0/24 via 10.101.1.1 dev eth1 || true
sudo ip route add 10.107.1.0/24 via 10.101.1.1 dev eth1 || true
sudo ip route add 10.1.1.0/24 via 10.101.1.1 dev eth1 || true
sudo ip route add 40.0.0.0/24 via 10.101.1.1 dev eth1 || true
sudo ip route add 50.0.0.0/24 via 10.101.1.1 dev eth1 || true
sudo ip -6 route add fc00:0::/32 via fc00:0:101:1::1 dev eth1 || true
sudo ip -6 route add fc00:0:40::1/64 via fc00:0:101:1::1 dev eth1 || true
sudo ip -6 route add fc00:0:50::1/64 via fc00:0:101:1::1 dev eth1 || true
"

# Execute
run_remote "$ROME_IP" "$ROME_CMDS"
run_remote "$LONDON_IP" "$LONDON_CMDS"

echo "Done."
