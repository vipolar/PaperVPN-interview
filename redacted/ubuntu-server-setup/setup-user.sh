#!/bin/bash

# Make sure only non-root can run the script
if [[ $EUID -ne 0 ]]; then
   echo "Elevated permissions are required to setup new user!" 1>&2
   exit 1
fi

USERNAME="${USERNAME:-"default"}"
GIT_EMAIL="${GIT_EMAIL:-"example@mail.com"}"
GIT_USERNAME="${GIT_USERNAME:-$USERNAME}"
GIT_EDITOR="${GIT_EDITOR:-"vim"}"

echo -e "Make sure every variable is set to a desired value:\n\tUSERNAME: $USERNAME\n\tGIT_EMAIL: $GIT_EMAIL\n\tGIT_USERNAME: $GIT_USERNAME\n\tGIT_EDITOR: $GIT_EDITOR"
read -p "If you're satisfied with the script type 'yes' to proceed : " PROMPT
if [[ "$PROMPT" != "yes" ]]; then
    exit
fi

adduser $USERNAME
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/"$USERNAME" > /dev/null
chmod 0440 /etc/sudoers.d/"$USERNAME"

su -l $USERNAME -c "git config --global user.email "$GIT_EMAIL""
su -l $USERNAME -c "git config --global user.name "$GIT_USERNAME""
su -l $USERNAME -c "git config --global core.editor "$GIT_EDITOR""
