#!/bin/bash

# Puppet Task Name: change_sshd_match_group
#

if [ $(whoami) != root ]; then
        echo "Not running as root, use '--run-as root' and possibly '--sudo-password-prompt'"
        exit 1
fi

DATE="$(date +"%F-%H-%M-%S")"
changeFlag=0

if [[ $PT_group ]]; then
	if [[ ! -e $PT_sshdconfiglocation ]]; then
		echo "sshd_config location is invalid! If not set via a parameter, than the target server may not use the default location."
		exit 2

	elif [[ $(grep $PT_group $PT_sshdconfiglocation) != "Match Group $PT_group" ]]; then
		cp $PT_sshdconfiglocation $PT_sshdconfiglocation.bak.$DATE
		echo -e "\nMatch Group $PT_group" >> $PT_sshdconfiglocation

	elif [[ $(grep $PT_group $PT_sshdconfiglocation) == "Match Group $PT_group" ]]; then
		cp $PT_sshdconfiglocation $PT_sshdconfiglocation.bak.$DATE
		sshdSectionOrig=$(grep -Pzo "(Match Group $PT_group)(\n(\t|\s+)\w.+)*" $PT_sshd_config_location)
		
		if [[ $(expr match $PT_pubkeyauth '^\(y\|Y\)') ]]; then
			grepForPubkeyEntry=$(echo "$sshdSectionOrig" | grep PubkeyAuthentication | sed -e 's/\t//g')
			if [[ $grepForPubkeyEntry == "PubkeyAuthentication yes" ]]; then
				echo "Entry for PubkeyAuthentication is already present as 'yes'"
				echo "$sshdSectionOrig"	
			elif [[ $grepForPubkeyEntry == "PubkeyAuthentication no" ]]; then
				sshdSectionNew=$(echo $sshdSectionOrig | sed -e 's/PubkeyAuthentication no/PubkeyAuthentication yes/g')
				changeFlag=1
			elif [[ -z $grepForPubkeyEntry ]]; then
				sshdSectionNew=$(echo -e "$sshdSectionOrig \n\tPubkeyAuthentication yes")
				echo -e $sshdSectionNew
				echo -e $sshdSectionOrig
				sed -i "s/$sshdSectionOrig/$sshdSectionNew/g" $PT_sshdconfiglocation
			fi 
		fi
		if [[ $changeflag -eq 1 ]]; then
			sed -i "s/$sshdSectionOrig/$sshdSectionNew/g" $PT_sshdconfiglocation
		fi
	else
		echo "An unhandled exception of some kind occurred."
	fi
elif [[ -z $PT_group ]]; then
	echo "No group provided."
fi
