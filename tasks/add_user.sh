#!/bin/bash

# Puppet Task Name: add_user
#

if [ $(whoami) != root ]; then
	echo "Not running as root, use '--run-as root' and '--sudo-password-prompt'"
	exit 1
fi

if [ ! -z $PT_username ]; then
	id -u $PT_username &> /dev/null
	if [ $? -eq 0 ]; then
		echo 'User account already exists.'
		if [ ! -z $PT_password ]; then
			echo 'Changing password.'
			echo $PT_username:$PT_password | chpasswd
		fi
	elif [ ! -z $PT_password ]; then
		echo "$PT_username created with the supplied password."
		useradd -m -s /bin/bash $PT_username 
		echo $PT_username:$PT_password | chpasswd
	else
		echo "No password supplied, created account for $PT_username without a password. You can set the password later."
		useradd -m -s /bin/bash $PT_username 
	fi
	if [ ! -z $PT_addusertosudo] && [ $(expr match $PT_addusertosudo '^\(y\|Y\)') ]; then
		if [ $(getent group sudo) ]; then
			usermod -aG sudo $PT_username
		elif [ $(getent group wheel) ]; then
			usermod -aG wheel $PT_username
		fi
	fi
else
	echo "No username provided."
fi

if [ ! -z $PT_group ]; then 
	if [ ! $(getent group $PT_group) ]; then
		echo "Adding $PT_group to groups." 
		groupadd $PT_group
		if [ ! -z $PT_username ]; then
			echo "Adding $PT_username to $PT_group"
			usermod -aG $PT_group $PT_username
		fi
	fi
	if [[ $(getent group $PT_group) ]] || [[ ! $(grep PT_group /etc/sudoers.d/*) ]]; then
		if [ $(expr match $PT_addgrouptosudoers '^\(y\|Y\)') ]; then
                        echo "Adding sudoers entry for group in /etc/sudoer.d."
                        echo -e "\n#Line added by admin via Puppet Bolt script \n%$PT_group    ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/$PT_group
                elif [ $(expr match $PT_addgrouptosudoers '^\(n\|N\)' ) ]; then
                        echo "Skipping adding group to sudoers. 'N' or 'n' given in parameter. "
                elif [ ! -z $PT_addgrouptosudoers ]; then
                        echo "Entry for addsudoers parameter is invalid. Needs to be either y or Y."
                fi
	elif [[ $(grep PT_group /etc/sudoers.d/*) ]]; then
		echo "Group $PT_group already appears under sudoer.d"
	else
		echo "Uncaught exception in creating sudoers.d entry for group $PT_group"
	fi
fi
