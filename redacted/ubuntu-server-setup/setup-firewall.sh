#!/bin/bash

# Make sure only root can run the script
if [[ $EUID -ne 0 ]]; then
   echo "Elevated permissions are required to set firewall rules!" 1>&2
   exit 1
fi

cat ufw/ufw-docker.rule >> /etc/ufw/after.rules

ufw reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 80
ufw route allow proto tcp from any to any port 80
ufw allow 443
ufw route allow proto tcp from any to any port 443
ufw allow 2503/tcp
ufw enable
