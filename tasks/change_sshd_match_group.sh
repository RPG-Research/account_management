#!/bin/bash
	
# Puppet Task Name: change_sshd_match_group
#

if [ $(whoami) != root ]; then
        echo "Not running as root, use '--run-as root' and possibly '--sudo-password-prompt'"
        exit 1
fi

passwordauth () {
	# Presently lacking code for switching password auth on yet ...
	# $1 is expected to be the parameter, $2 is expected to be the group name, $3 is expected to be the sshd_config location 
	if [[ $(expr match $1 '^\(n\|N\)') ]]; then
		sshdSectionOrig=$(grep -Pzo "(Match Group $PT_group)(\n(\t|\s+)\w.+)*" $PT_sshdconfiglocation)
		grepForPubkeyEntry=$(echo "$sshdSectionOrig" | grep PasswordAuthentication | sed -e 's/\t//g')
		echo "passwordauth parameter is 'No'..."
		if [[ $grepForPasswordEntry == "PasswordAuthentication no" ]]; then
			echo "Entry for PasswordAuthentication is already present as 'no'"
			echo "$sshdSectionOrig"
		elif [[ $grepForPubkeyEntry == "PasswordAuthentication no" ]]; then
			echo "PubkeyAuthentication set to no, changing...."
			awk -i inplace -v group="$2" -v addedText="\tPasswordAuthentication no\n" -v origText="\tPasswordAuthentication yes" '/Match Group '$group'/,/^$/ {gsub(origText, addedText)};{print; 1}' $3
		elif [[ -z $grepForPasswordEntry ]]; then
			echo "PasswordAuthentication not found, adding this entry..."
			awk -i inplace -v group="$2" -v addedText="\tPasswordAuthentication no\n" '/Match Group '$group'/,/^$/ {gsub(/^$/, addedText)};{print; 1}' $3
		fi
	fi
}

pubkeyauth () {
	# Presently lacking code for switching pubkeyauth off...
	# $1 is expected to be the parameter, $2 is expected to be the group name, $3 is expected to be the sshd_config location
	if [[ $(expr match $PT_pubkeyauth '^\(y\|Y\)') ]]; then
		sshdSectionOrig=$(grep -Pzo "(Match Group $2)(\n(\t|\s+)\w.+)*" $3)
		echo "pubkeyauth parameter is true..."
		grepForPubkeyEntry=$(echo "$sshdSectionOrig" | grep PubkeyAuthentication | sed -e 's/\t//g')
		if [[ $grepForPubkeyEntry == "PubkeyAuthentication yes" ]]; then
			echo "Entry for PubkeyAuthentication is already present as 'yes'"
			echo "$sshdSectionOrig"
		elif [[ $grepForPubkeyEntry == "PubkeyAuthentication no" ]]; then
			echo "PubkeyAuthentication set to no, changing...."
			awk -i inplace -v group="$2" -v addedText="\tPubKeyAuthentication yes" -v origText="\tPubKeyAuthentication no" '/Match Group '$group'/,/^$/ {gsub(origText, addedText)};{print; 1}' $3
		elif [[ -z $grepForPubkeyEntry ]]; then
			echo "PubkeyAuthentication not found, adding..."
			awk -i inplace -v group="$2" -v addedText="\tPubkeyAuthentication yes" '/Match Group '$group'/,/^$/ {gsub(/^$/, addedText)};{print; 1}' $3
		fi
	fi
}

if [[ $PT_group ]]; then
	DATE="$(date +"%F-%H-%M-%S")"
	echo "Group provided is: "$PT_group
	echo "Location of sshd_config is:" $PT_sshdconfiglocation

	if [[ ! -e $PT_sshdconfiglocation ]]; then
		echo "sshd_config location is invalid! If not set via a parameter, than the target server may not use the default location."
		exit 2
	elif [[ $(grep $PT_group $PT_sshdconfiglocation) != "Match Group $PT_group" ]]; then
		cp $PT_sshdconfiglocation $PT_sshdconfiglocation.bak.$DATE
		echo -e "\nMatch Group $PT_group" >> $PT_sshdconfiglocation
	elif [[ $(grep $PT_group $PT_sshdconfiglocation) == "Match Group $PT_group" ]]; then
		cp $PT_sshdconfiglocation $PT_sshdconfiglocation.bak.$DATE
		echo $PT_group "section found"
	fi

	# Here we launch the actual functions defined above

	if [[ $(expr match $PT_pubkeyauth '^\(\(n\|N\)\|\(y\|Y\)\)') ]]; then
		pubkeyauth "$PT_pubkeyauth" "$PT_group" "$PT_sshdconfiglocation"
	fi
	if [[ $(expr match $PT_passwordauth '^\(\(n\|N\)\|\(y\|Y\)\)') ]]; then
		passwordauth "$PT_passwordauth" "$PT_group" "$PT_sshdconfiglocation"
	fi
elif [[ -z $PT_group ]]; then
	echo "No group provided."
fi
