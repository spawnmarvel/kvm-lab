# IT/OT automation zabbix stack study and prepare


## Table of content
- [IT/OT automation zabbix stack study and prepare](#itot-automation-zabbix-stack-study-and-prepare)
  - [Table of content](#table-of-content)
  - [1. Available Automation Tools for Installing Zabbix](#1-available-automation-tools-for-installing-zabbix)
  - [2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?](#2-is-ansible-a-good-choice-for-maintaining-ubuntu-and-windows-hosts)
  - [The 5-Level Hierarchy (Shared by Purdue \& ISA-95)](#the-5-level-hierarchy-shared-by-purdue--isa-95)

## 1. Available Automation Tools for Installing Zabbix

In short, several standard tools exist for installing and managing Zabbix, but Ansible is widely considered the industry standard for this exact mix of Linux (Ubuntu) and Windows hosts across Purdue OT zones.

1. Ansible
2. Cloud-Init
3. HashiCorp Packer
4. Puppet / Chef
## 2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?


Yes, Ansible is the best selection for your environment. It handles heterogenous OS fleets (Ubuntu + Windows) under strict network restrictions better than most alternatives for several key reasons:



## The 5-Level Hierarchy (Shared by Purdue & ISA-95)