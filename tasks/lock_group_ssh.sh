#!/bin/sh

# Puppet Task Name: lock_group_ssh
#

PT_sshd_config_location

if [[ $PT_group ]]; then
	if [[ $(grep $PT_group $PT_sshd_config_location) == 'Match Group $PT_sshd_config_location' ]]; then
		sshdSection=$(grep -Pzo "(Match Group $PT_group)(\n\t.+)*" $PT_sshd_config_location)
		echo "$sshdSection"
	fi
elif [[ -z $PT_group ]]; then
	echo "No group provided."
fi
