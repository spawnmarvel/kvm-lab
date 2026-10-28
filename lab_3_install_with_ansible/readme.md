# Ansible

## Table of content

- [Ansible](#ansible)
  - [Table of content](#table-of-content)
  - [Here's a quick guide to get you up to speed on Ansible](#heres-a-quick-guide-to-get-you-up-to-speed-on-ansible)
  - [Install Ansible on host](#install-ansible-on-host)
  - [Core Concepts](#core-concepts)
  - [Install Mysql](#install-mysql)
  - [Install Zabbix](#install-zabbix)
  - [Install Zabbix proxy](#install-zabbix-proxy)

## Here's a quick guide to get you up to speed on Ansible


## Install Ansible on host


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


## Install Mysql

It is default 8.4 LTS on ubunut 26.04

## Install Zabbix

## Install Zabbix proxy


