#!/bin/bash

# Start FRR daemons as per the daemons file
/usr/lib/frr/frrinit.sh start

# Keep the container running
tail -f /dev/null