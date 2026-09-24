#!/bin/bash

if [[ $EUID -eq 0 ]]; then
	echo "Do not run this script as root!" 1>&2
	exit 1
fi

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 {install|launch|update|uninstall}" 1>&2
	exit 1
fi

case "$1" in
install)
	LATEST_URL=$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest |
		grep "browser_download_url.*linux-amd64-filebrowser.tar.gz" | cut -d '"' -f 4)

	if [[ -z "$LATEST_URL" ]]; then
		echo "Failed to fetch the latest release URL." 1>&2
		exit 1
	fi

	wget "$LATEST_URL" -O filebrowser.tar.gz
	tar -xvf filebrowser.tar.gz
	rm filebrowser.tar.gz

	echo "Filebrowser installed successfully."
	;;
launch)
	if [[ ! -f "filebrowser" ]]; then
		echo "Filebrowser is not installed. Run '$0 install' first." 1>&2
		exit 1
	fi

	./filebrowser --address localhost --port 7869 --root ..
	;;
update)
	echo "Filebrowser update has to be done manually for now."
	#$0 uninstall
	#$0 install
	;;
uninstall)
	rm -rf *
	echo "Filebrowser uninstalled successfully."
	;;
*)
	echo "Invalid argument: $1" 1>&2
	echo "Usage: $0 {install|launch|update|uninstall}" 1>&2
	exit 1
	;;
esac
