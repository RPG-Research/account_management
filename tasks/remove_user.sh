#!/bin/bash

# Puppet Task Name: remove_user
#

if [ $(whoami) != root ]; then
	echo "Not running as root, use '--run-as root' and '--sudo-password-prompt'"
	exit 1
fi

if [ ! -z $PT_username ]; then
	id -u $PT_username &> /dev/null
	if [ $? -eq 0 ]; the
		echo "Account exists, removing..."
		if [[ $PT_removeFiles == 'true' ]]; then
			userdel -r $PT_username
		elif [[ $PT_removeFile == 'false' ]]; then
			userdel $PT_username
		fi
	elif [[ $? -eq 1 ]] || [[ $? -eq 2 ]]; then
		echo "A problem occurred in finding the provided account."
		grep -i $PT_username /etc/passwd
	fi
fi
