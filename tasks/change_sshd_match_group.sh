#!/bin/bash
	
# Puppet Task Name: change_sshd_match_group
#

if [ $(whoami) != root ]; then
        echo "Not running as root, use '--run-as root' and possibly '--sudo-password-prompt'"
        exit 1
fi

DATE="$(date +"%F-%H-%M-%S")"
changeFlag=0
echo "Group is: "$PT_group
echo "sshd_config is:" $PT_sshdconfiglocation

function apply_changes () {
        echo -e "We're changing:\n$sshdSectionOrig\n"
        echo -e "To:\n$sshdSectionNew"
	sed -i "s|$(echo -e "$1" | sed -e $'N;s/[\\n\r])/$(echo -e "$s2" | sed -e $'N;s/[\\n\r]//g' -e 's/       /\\n\\t/g')/g' -e 's/       /\\n\\t/g')|$2|g" $3	
}

if [[ $PT_group ]]; then
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

	echo $sshdSectionOrig

	if [[ $(expr match $PT_pubkeyauth '^\(y\|Y\)') ]]; then
		sshdSectionOrig=$(grep -Pzo "(Match Group $PT_group)(\n(\t|\s+)\w.+)*" $PT_sshdconfiglocation)
		echo "pubkeyauth parameter is true..."
		grepForPubkeyEntry=$(echo "$sshdSectionOrig" | grep PubkeyAuthentication | sed -e 's/\t//g')
		if [[ $grepForPubkeyEntry == "PubkeyAuthentication yes" ]]; then
			echo "Entry for PubkeyAuthentication is already present as 'yes'"
			echo "$sshdSectionOrig"	
		elif [[ $grepForPubkeyEntry == "PubkeyAuthentication no" ]]; then
			echo "PubkeyAuthentication set to no, changing...."
			sshdSectionNew=$(echo $sshdSectionOrig | sed -e 's/PubkeyAuthentication no/PubkeyAuthentication yes/g')
                        apply_changes '"$sshdSectionOrig"' '"$sshdSectionNew"' "$PT_sshdconfiglocation"
		elif [[ -z $grepForPubkeyEntry ]]; then
			echo "PubkeyAuthentication not found, adding..."
			#For the line below, escapes are required for \ so sed does not break
			sshdSectionNew=$(echo -e "$sshdSectionOrig"'\\n\\tPubkeyAuthentication yes' | sed -e $'N;s/[\\n\r]//g' -e 's/   /\\n\\t/g')
                        apply_changes "$sshdSectionOrig" "$sshdSectionNew" "$PT_sshdconfiglocation"
		fi 
	fi
	if [[ $(expr match $PT_passwordauth '^\(n\|N\)') ]]; then
		sshdSectionOrig=$(grep -Pzo "(Match Group $PT_group)(\n(\t|\s+)\w.+)*" $PT_sshdconfiglocation)
		echo "passwordauth parameter is true..."
		grepForPasswordEntry=$(echo "$sshdSectionOrig" | grep PasswordAuthentication | sed -e 's/\t//g')
		if [[ $grepForPasswordEntry == "PasswordAuthentication no" ]]; then
			echo "Entry for PasswordAuthentication is already present as 'no'"
			echo "$sshdSectionOrig"
		elif [[ $grepForPubkeyEntry == "PasswordAuthentication no" ]]; then
			echo "PubkeyAuthentication set to no, changing...."
			sshdSectionNew=$(echo $sshdSectionOrig | sed -e 's/PasswordAuthentication no/PasswordAuthentication yes/g')
			apply_changes "$sshdSectionOrig" "$sshdSectionNew" "$PT_sshdconfiglocation"
		elif [[ -z $grepForPasswordEntry ]]; then
			echo "PasswordAuthentication not found, adding..."
			#For the line below, escapes are required for \ so sed does not break
			sshdSectionNew=$(echo -e "$sshdSectionOrig"'\\n\\tPasswordAuthentication no' | sed -e $'N;s/[\\n\r]/\\n/g' -e 's/       /\\n\\t/g')
			apply_changes "$sshdSectionOrig" "$sshdSectionNew" "$PT_sshdconfiglocation"
		fi
	fi
elif [[ -z $PT_group ]]; then
	echo "No group provided."
fi
