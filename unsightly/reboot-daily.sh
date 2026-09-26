#!/bin/bash

LOG_FILE="/home/smart-portal/smart-portal-cms/reboot-script.log"

# Function to log messages
log_message() {
	echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check if a package management operation is running
is_update_in_progress() {
	log_message "Checking for lock files and processes."

	# Check for the presence of dpkg and apt lock files and if they are being used
	if fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then
		log_message "Lock file /var/lib/dpkg/lock-frontend is in use."
		return 0
	fi

	if fuser /var/lib/dpkg/lock >/dev/null 2>&1; then
		log_message "Lock file /var/lib/dpkg/lock is in use."
		return 0
	fi

	if fuser /var/lib/apt/lists/lock >/dev/null 2>&1; then
		log_message "Lock file /var/lib/apt/lists/lock is in use."
		return 0
	fi

	if fuser /var/cache/apt/archives/lock >/dev/null 2>&1; then
		log_message "Lock file /var/cache/apt/archives/lock is in use."
		return 0
	fi

	# Check for specific running processes
	if pgrep -x "apt-get" > /dev/null; then
		log_message "Process apt-get is running."
		return 0
	fi

	if pgrep -x "dpkg" > /dev/null; then
		log_message "Process dpkg is running."
		return 0
	fi

	if pgrep -x "apt" > /dev/null; then
		log_message "Process apt is running."
		return 0
	fi

#	if pgrep -x "unattended-upgr" > /dev/null; then
#		log_message "Process unattended-upgr is running."
#		return 0
#	fi

	return 1
}

# Check if an update process is running
if is_update_in_progress; then
	log_message "Update in progress, scheduling reboot check in 15 minutes."
	echo "/home/smart-portal/smart-portal-cms/reboot-script.sh" | at now + 15 minutes
	exit 0
else
	log_message "No update in progress, proceeding to reboot."
	while true; do
		sudo /sbin/reboot
		sleep 15
	done
fi
