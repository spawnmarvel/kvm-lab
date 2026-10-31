# IT/OT automation zabbix stack study and prepare


## Table of content
- [IT/OT automation zabbix stack study and prepare](#itot-automation-zabbix-stack-study-and-prepare)
  - [Table of content](#table-of-content)
  - [The 5-Level Hierarchy (Shared by Purdue \& ISA-95)](#the-5-level-hierarchy-shared-by-purdue--isa-95)
  - [1. Available Automation Tools for Installing Zabbix](#1-available-automation-tools-for-installing-zabbix)
  - [2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?](#2-is-ansible-a-good-choice-for-maintaining-ubuntu-and-windows-hosts)
  - [3. No docker in a strict Purdue Model](#3-no-docker-in-a-strict-purdue-model)


## The 5-Level Hierarchy (Shared by Purdue & ISA-95)

## 1. Available Automation Tools for Installing Zabbix

In short, several standard tools exist for installing and managing Zabbix, but Ansible is widely considered the industry standard for this exact mix of Linux (Ubuntu) and Windows hosts across Purdue OT zones.

1. Ansible
2. Cloud-Init
3. HashiCorp Packer
4. Puppet / Chef
   
  
## 2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?


Yes, Ansible is the best selection for your environment. It handles heterogenous OS fleets (Ubuntu + Windows) under strict network restrictions better than most alternatives for several key reasons:


## 3. No docker in a strict Purdue Model

In a strict Purdue Model / IEC 62443 industrial control context, running Docker in Zone 2 is generally avoided due to:

* Security & Attack Surface: Docker daemons run as root and introduce container bridge interfaces, dynamic iptables rules, and potential privilege escalation vectors inside critical control zones.

* Network Transparency: Dynamic container networking (NAT/overlay bridge networks) complicates strict, stateful firewall tracking between Zone 2 and Zone 2.5.

* Operational Overhead: Adding container engines to low-level control zone hosts adds extra update, dependency, and vulnerability management overhead.

Native systemd services (zabbix-proxy-sqlite3 on bare-metal or system systemd on lightweight KVM/Ubuntu VMs) provide a cleaner, highly predictable security profile for OT environments.


## Scenario 1

### 1. Scenario & Core Requirements Summary


Datacenter Handover: The datacenter build team manually provisions clean Ubuntu 26.04 and Windows Server VMs via GUI. Day-2 automation begins immediately after IP and credential handover.

Target Stack:

* Zone 2.5 (iDMZ): 

* * 1 Zabbix Server (native Ubuntu 26.04 package), name zabbix01
* * 1 MySQL 8.4 LTS Server with an extra 60GB data (native Ubuntu 26.04 package), name mysql01

* Zone 2 (Control/OT): 1 Zabbix Active Proxy server (Ubuntu 26.04 + SQLite3), name zabbix02

* Zone 2 (Control/OT): 20–30 Windows VMs running Zabbix Agent2.

Operational Goal: 

1. Keep IT/OT secure and follow Purdue and ISA-95 as guidelines
2. Eliminate repetitive manual apt commands and external firewall URL whitelisting (repo.zabbix.com, archive.ubuntu.com, security.ubuntu.com) for every new datacenter.
3. Only one server, the Ansible control node will have access out(*) and can run internal automation.

(*) Out in this case can be internet or a private mirror server hosted outside of the network or a mirror server hosted inside the network.

For this spesific scenario, out is internet.

* Zone 2.5 (iDMZ): 1 Ansible control node server (native Ubuntu 26.04 package) and apache (not Nginx), name ansiblectr01
* ansiblectr01must be able to update zabbix01, mysql01 and zabbix02
* MySQL 8.4 LTS Server datadrive name is datadrive1 and used for storing mysql

Excluded Items:

* WSUS is omitted for this iteration.

Firewall requirements.

1. ansiblectr01 port 80, 443 to ?
2. zabbix01 ?
3. mysql01 ?
4. zabbix02 ?


### 2. Why apt-cacher-ng Was Selected


Storage Footprint

* debmirror / aptly: To host a full local mirror of Ubuntu 26.04 (main, universe, security) and Zabbix 7.0 LTS repositories, ansiblectr01 would require 200 GB to 350+ GB of dedicated disk space just to hold thousands of packages you will never use.

* apt-cacher-ng: Uses a dynamic cache footprint (typically 2 GB to 5 GB). It only downloads and stores the exact .deb packages requested by zabbix01, mysql01, and zabbix02.

Maintenance Overhead

* debmirror / aptly: Requires scheduling periodic cron jobs to download tens of gigabytes of repository diffs, managing local GPG keys, handling mirror sync failures, and publishing distribution snapshots.

* apt-cacher-ng: Requires zero daily maintenance. When a node runs apt update && apt upgrade, apt-cacher-ng passes the request through its single outbound connection, caches the downloaded .deb files locally, and serves future installs directly from storage.

Summary Recommendation

* Stick with apt-cacher-ng: It gives you the exact single-egress control required by your Purdue security design without wasting 300 GB of storage or creating ongoing mirror management tasks on ansiblectr01

* Use aptly or debmirror only if: The datacenter network is completely air-gapped (no outbound internet at all, even on ansiblectr01), forcing you to import entire package repositories via physical media.

