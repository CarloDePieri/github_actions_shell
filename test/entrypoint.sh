#!/bin/bash

# Make sure sshd is up and running
a=$(/etc/init.d/ssh start 2>&1 >/dev/null)

# Launch the script
/src/connect

