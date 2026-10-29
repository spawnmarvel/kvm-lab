# Ansible

## Table of content

- [Ansible](#ansible)
  - [Table of content](#table-of-content)
- [Here's a quick guide to get you up to speed on Ansible](#heres-a-quick-guide-to-get-you-up-to-speed-on-ansible)
  - [Core Concepts](#core-concepts)
  - [Key Advantages](#key-advantages)
  - [Ansible Agentless Architecture Linux and Windows](#ansible-agentless-architecture-linux-and-windows)
- [Install Ansible on host](#install-ansible-on-host)
  - [Getting started with Ansible GOTO tutorial\_ansible](#getting-started-with-ansible-goto-tutorial_ansible)
- [install online](#install-online)
  - [Install Mysql](#install-mysql)
  - [Install Zabbix](#install-zabbix)
  - [Install Zabbix proxy](#install-zabbix-proxy)
- [install offline](#install-offline)
  - [Install Mysql](#install-mysql-1)
  - [Install Zabbix](#install-zabbix-1)
  - [Install Zabbix proxy](#install-zabbix-proxy-1)

# Here's a quick guide to get you up to speed on Ansible


## Core Concepts

* Control Node: The machine where Ansible is installed and commands are executed.

* Managed Nodes: The target servers, network devices, or VMs managed by Ansible.

* Inventory: A text file (INI or YAML) listing managed hosts grouped by environment or function.

* Playbook: A YAML file containing a sequence of plays and tasks that define the desired system state.

* Modules: Built-in Python scripts executed on targets to perform specific actions (e.g., package installation, file editing, service management).

* Roles: Modular, reusable directory structures for organizing playbooks, variables, and tasks.

## Key Advantages

* Agentless Architecture: Eliminates the need to maintain background daemons or agents on target systems.

* Declarative Language: Written in human-readable YAML focusing on what state the system should be in rather than how to achieve it.

* Idempotency: Tasks can run repeatedly without changing the system state if the desired outcome is already present.

## Ansible Agentless Architecture Linux and Windows

* On Linux, Ansible connects via SSH, authenticates using SSH keys or passwords, and transfers small Python modules to the /tmp directory on the target system. It executes those modules using the target's Python interpreter to apply the desired configuration, retrieves the JSON result, and automatically removes the temporary script files.

* On Windows, Ansible connects over WinRM (Windows Remote Management) or WinSSHD, authenticates using NTLM, Kerberos, or CredSSP, and executes PowerShell scripts or .NET code directly in memory. Results are captured in JSON format and returned to the control node without leaving persistent software behind.


# Install Ansible on host

```bash
# install all


# verify all
```

## Getting started with Ansible GOTO tutorial_ansible



# install online

## Install Mysql

It is default 8.4 LTS on ubunut 26.04

## Install Zabbix

## Install Zabbix proxy

# install offline

## Install Mysql

It is default 8.4 LTS on ubunut 26.04

## Install Zabbix

## Install Zabbix proxy


