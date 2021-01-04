# account-management

This is a Puppet Bolt module generated using PDK. A short overview of the generated parts can be found
in the PDK documentation.

The README template below provides a starting point with details about what
information to include in your README.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with zabbix_agent](#setup)
    * [What account_management affects](#what-account_management-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with account_management](#beginning-with-account_management)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module is a selection of scripts meant to allow adding and removing Linux/Unix
users, removing them, adding them to sudoers, adding them to groups, adding the groups
to sudoers, and modifying sshd_config for group specific settings.

Many tasks/scripts may be best moved into seperate scripts/tasks to reduce the number
of needed parameters and to clarify the purpose/abilities of each script to reduce the necessity
of documentation/reading.

There are currently no Bolt Plans under this project, and all scripts are in Bash.

## Setup

### What account_management affects **OPTIONAL**

Depending on the task and parameters, this module can be expected to affect the contents of the
following directories on target machines: /etc/passwd, /etc/shadow, /etc/sudoers.d/*, /etc/ssh/sshd_config,
/home/*.

### Setup Requirements **OPTIONAL**

An existing Bolt project is needed, and the user account on the remote system needs to have bash available.

### Beginning with account_management


## Usage

Git clone this repo to your site-modules/.

try "bolt task show account_management::add_user" or "bolt task show account_management::change_sshd_match_group". You will need to "bolt task run" with the right parameters. 

## Limitations

Bash dependent.

Amateurishly written, and handling of passwords for new accounts should not be considered secure.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

# account_management

