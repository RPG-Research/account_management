# Changelog

All notable changes to this project will be documented in this file.

## Release 0.1.1

**Features**

Current features are limited.

There is a create user script. A remove user script. And a in progress script to modify the SSHd config for adding, removing, or changing a section for a particular group (i.e. remove passwords for a Puppet Bolt group).

**Bugfixes**

Fixed group file creation under sudoers.d in add_user.sh by correcting the noexistent $group variable to $PT_group.

**Known Issues**

OS specific to Linux.

Not yet tested for BSD based OS', but should be compatible if the account used has access to Bash (but some commands in these scripts may break).

Password handling in add_user script should be regarded as insecure - as it likely is insecure, and there is likely to be data remnance of the password on both the client and target server.  The assumption is that the user will change their password shortly after creation, and it should be used as such.

Right now there is no "Pattern" matching within the Bolt JSON definitions of any script. There was an attempt to use pattern matching in the parameter definitions such as '(y|Y)|(n|N)', which is also done within the relevant scripts, but these parameters created strange breaks and will need to be revisited.

Originally designed for a particular use case - for creating and modifying accounts from Puppet Bolt *for* Puppet Bolt.

Includes some features that may be best to seperate, such as modifying the SSH config. The thought behind the SSH config modification is that it is specifically adjusting group/user access, and was not substantial enough for its own module. 

No Shell selection in add_user user creation, defaults to Bash.

No user environment or group modification script. Changing of passwords is part of the user creation script, this is probably best to seperate.
