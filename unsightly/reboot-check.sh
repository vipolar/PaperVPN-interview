#!/bin/bash

LOG_FILE="/home/smart-portal/smart-portal-cms/reboot-daily.log"

# Function to log messages
log_message() {
	echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
	log_message "Reboot required! Rebooting the system..."
	while true; do
		sudo /sbin/reboot
		sleep 15
	done
else
	log_message "No reboot is required."
fi
