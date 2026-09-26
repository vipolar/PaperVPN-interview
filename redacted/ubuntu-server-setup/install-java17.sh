#!/bin/bash
JAVA_MAJOR=17

# Make sure only root can run the script
if [[ $EUID -ne 0 ]]; then
   echo "Elevated permissions are required to install java!" 1>&2
   exit 1
fi

apt-get install openjdk-$JAVA_MAJOR-jdk openjdk-$JAVA_MAJOR-jre maven -y