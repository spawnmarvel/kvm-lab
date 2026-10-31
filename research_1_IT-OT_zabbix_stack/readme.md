# IT/OT automation zabbix stack study and prepare


## Table of content
- [IT/OT automation zabbix stack study and prepare](#itot-automation-zabbix-stack-study-and-prepare)
  - [Table of content](#table-of-content)
  - [The 5-Level Hierarchy (Shared by Purdue \& ISA-95)](#the-5-level-hierarchy-shared-by-purdue--isa-95)
  - [1. Available Automation Tools for Installing Zabbix](#1-available-automation-tools-for-installing-zabbix)
  - [2. Is Ansible a Good Choice for Maintaining Ubuntu and Windows Hosts?](#2-is-ansible-a-good-choice-for-maintaining-ubuntu-and-windows-hosts)
  - [3. No docker in a strict Purdue Model](#3-no-docker-in-a-strict-purdue-model)
  - [Scenario 1](#scenario-1)
    - [1. Scenario \& Core Requirements Summary](#1-scenario--core-requirements-summary)
    - [2. Why apt-cacher-ng Was Selected](#2-why-apt-cacher-ng-was-selected)
    - [3. Firewall Rule Matrix (Purdue / ISA-95 Architecture)](#3-firewall-rule-matrix-purdue--isa-95-architecture)
      - [3.1 Firewall rules and diagram](#31-firewall-rules-and-diagram)
    - [4. Toplogy for POC to build with KVM](#4-toplogy-for-poc-to-build-with-kvm)
    - [GOTO run\_research\_1\_IT-OT\_zabbix\_stack](#goto-run_research_1_it-ot_zabbix_stack)


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

### 3. Firewall Rule Matrix (Purdue / ISA-95 Architecture)


This security defense proposal outlines the architectural justification for the Day-2 Zabbix monitoring and Ansible configuration management stack deployed across Zone 2.5 (iDMZ) and Zone 2 (Control/OT).

#### 3.1 Firewall rules and diagram

GOTO research_1_IT-OT_zabbix_stack/firewall_rule_matrix.md


Or https://github.com/spawnmarvel/kvm-lab/blob/main/research_1_IT-OT_zabbix_stack/firewall_rule_matrix.md

Firewall Rule Matrix (Purdue / ISA-95 Architecture)

| Rule ID    | Source Host           | Source Zone         | Destination FQDN / Host                          | Destination Zone    | Protocol / Port      | Purpose                                             |
| :--------- | :-------------------- | :------------------ | :----------------------------------------------- | :------------------ | :------------------- | :-------------------------------------------------- |
| **FW-01a** | `ansiblectr01`        | Zone 2.5 (iDMZ)     | `archive.ubuntu.com`, `security.ubuntu.com`      | External / Internet | TCP 80, 443          | Ubuntu OS repository update traffic                 |
| **FW-01b** | `ansiblectr01`        | Zone 2.5 (iDMZ)     | `repo.zabbix.com`, `cdn.zabbix.com`              | External / Internet | TCP 80, 443          | Zabbix APT repository & Agent2 `.msi` downloads     |
| **FW-01c** | `ansiblectr01`        | Zone 2.5 (iDMZ)     | `ppa.launchpadcontent.net`, `galaxy.ansible.com` | External / Internet | TCP 80, 443          | Ansible PPA repository & Ansible Galaxy collections |
| **FW-02**  | `ansiblectr01`        | Zone 2.5 (iDMZ)     | `zabbix01`, `mysql01`                            | Zone 2.5 (iDMZ)     | TCP 22               | Ansible SSH configuration & management              |
| **FW-03**  | `ansiblectr01`        | Zone 2.5 (iDMZ)     | `zabbix02`                                       | Zone 2 (Control/OT) | TCP 22               | Ansible SSH configuration & management              |
| **FW-04**  | `ansiblectr01`        | Zone 2.5 (iDMZ)     | Windows VMs                                      | Zone 2 (Control/OT) | TCP 5985, 5986 or 22 | Ansible WinRM / SSH management                      |
| **FW-05**  | `zabbix01`, `mysql01` | Zone 2.5 (iDMZ)     | `ansiblectr01`                                   | Zone 2.5 (iDMZ)     | TCP 3142             | Internal APT package updates (`apt-cacher-ng`)      |
| **FW-06**  | `zabbix02`            | Zone 2 (Control/OT) | `ansiblectr01`                                   | Zone 2.5 (iDMZ)     | TCP 3142             | Internal APT package updates (`apt-cacher-ng`)      |
| **FW-07**  | Windows VMs           | Zone 2 (Control/OT) | `ansiblectr01`                                   | Zone 2.5 (iDMZ)     | TCP 80               | Apache HTTP download of `zabbix_agent2.msi`         |
| **FW-08**  | `zabbix01`            | Zone 2.5 (iDMZ)     | `mysql01`                                        | Zone 2.5 (iDMZ)     | TCP 3306             | MySQL database query traffic                        |
| **FW-09**  | `zabbix02`            | Zone 2 (Control/OT) | `zabbix01`                                       | Zone 2.5 (iDMZ)     | TCP 10051            | Active Proxy metric data push                       |
| **FW-10**  | Windows VMs           | Zone 2 (Control/OT) | `zabbix02`                                       | Zone 2 (Control/OT) | TCP 10051            | Zabbix Agent2 active metric submission              |
| **FW-11**  | Admin Workstations    | Level 3.5 (IT)      | `zabbix01`                                       | Zone 2.5 (iDMZ)     | TCP 80, 443          | Zabbix Web Frontend user interface access           |


### 4. Toplogy for POC to build with KVM

![topolgy it ot](https://github.com/spawnmarvel/kvm-lab/blob/main/images/topology_io_ot.jpeg)


### GOTO run_research_1_IT-OT_zabbix_stack



