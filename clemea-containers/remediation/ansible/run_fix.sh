#!/bin/bash

# Move to the directory where the script is located
cd "$(dirname "$0")"

echo "Starting remediation for Rome and London..."
ansible-playbook -i inventory.ini fix_eth1.yml "$@"

echo "Done."
