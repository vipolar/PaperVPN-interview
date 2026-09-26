#!/bin/bash

# Make sure only root can run the script
if [[ $EUID -ne 0 ]]; then
   echo "Elevated permissions are required to run full system upgrade!" 1>&2
   exit 1
fi

apt-get update
apt-get full-upgrade
apt-get install fail2ban -y
cp sshd/. /etc/ssh/sshd_config.d/
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban
