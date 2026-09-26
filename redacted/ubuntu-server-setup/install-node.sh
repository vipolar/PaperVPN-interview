#!/bin/bash
NODE_MAJOR=20

# Make sure only root can run the script
if [[ $EUID -ne 0 ]]; then
   echo "Elevated permissions are required to install nodeJS!" 1>&2
   exit 1
fi

apt install curl gnupg2 gnupg git wget -y
apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update && apt-get install nodejs -y