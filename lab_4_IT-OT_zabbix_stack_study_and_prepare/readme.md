# IT/OT automation zabbix stack study and prepare


## Table of content
- [IT/OT automation zabbix stack study and prepare](#itot-automation-zabbix-stack-study-and-prepare)
  - [Table of content](#table-of-content)
  - [The 5-Level Hierarchy (Shared by Purdue \& ISA-95)](#the-5-level-hierarchy-shared-by-purdue--isa-95)
  - [1. Available Automation Tools for Installing Zabbix](#1-available-automation-tools-for-installing-zabbix)
  - [2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?](#2-is-ansible-a-good-choice-for-maintaining-ubuntu-and-windows-hosts)
  - [3. No docker](#3-no-docker)


## The 5-Level Hierarchy (Shared by Purdue & ISA-95)

## 1. Available Automation Tools for Installing Zabbix

In short, several standard tools exist for installing and managing Zabbix, but Ansible is widely considered the industry standard for this exact mix of Linux (Ubuntu) and Windows hosts across Purdue OT zones.

1. Ansible
2. Cloud-Init
3. HashiCorp Packer
4. Puppet / Chef
   
  
## 2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?


Yes, Ansible is the best selection for your environment. It handles heterogenous OS fleets (Ubuntu + Windows) under strict network restrictions better than most alternatives for several key reasons:


## 3. No docker

In a strict Purdue Model / IEC 62443 industrial control context, running Docker in Zone 2 is generally avoided due to:

* Security & Attack Surface: Docker daemons run as root and introduce container bridge interfaces, dynamic iptables rules, and potential privilege escalation vectors inside critical control zones.

* Network Transparency: Dynamic container networking (NAT/overlay bridge networks) complicates strict, stateful firewall tracking between Zone 2 and Zone 2.5.

* Operational Overhead: Adding container engines to low-level control zone hosts adds extra update, dependency, and vulnerability management overhead.

Native systemd services (zabbix-proxy-sqlite3 on bare-metal or system systemd on lightweight KVM/Ubuntu VMs) provide a cleaner, highly predictable security profile for OT environments.
