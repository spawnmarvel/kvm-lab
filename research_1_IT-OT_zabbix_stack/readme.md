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
    - [4.1 Day-2 management](#41-day-2-management)
    - [4.1 Leg 2 complies with the Purdue Model and IEC 62443 / ISA-95 standards](#41-leg-2-complies-with-the-purdue-model-and-iec-62443--isa-95-standards)
    - [4.3 Teoretical steps for ansiblectr01](#43-teoretical-steps-for-ansiblectr01)
    - [4.4 Step-by-Step Flow: Manual Commands vs. Automated apt-cacher-ng](#44-step-by-step-flow-manual-commands-vs-automated-apt-cacher-ng)
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

* Zero Direct IT-to-OT Access: Level 3.5 / IT networks connect only to zabbix01 (web UI) and ansiblectr01 (SSH). They have no direct connectivity to Zone 2 OT devices.

* Push-Upward Monitoring: zabbix02 in Zone 2 connects outbound to zabbix01 in Zone 2.5 on TCP 10051. No inbound connection from Zone 2.5 into Zone 2 is required for monitoring.

* Air-Gapped Operational Zone: No host in Zone 2 has internet access. All updates and binaries are fetched strictly from ansiblectr01 over internal protocols (TCP 3142 and TCP 80).

### 4.1 Day-2 management

To understand how Day-2 management traffic flows while honoring Purdue security boundaries, trace the four distinct communication legs involved in provisioning and operating zabbix02:

* Leg 1: Administrative Access (Level 3.5 → Zone 2.5)
  An administrator opens an SSH session (TCP 22) from a workstation in Level 3.5 directly to ansiblectr01 (10.68.68.10) inside Zone 2.5 (iDMZ). Level 3.5 never initiates connections directly into Zone 2 OT devices.

* Leg 2: Automation Execution Push (Zone 2.5 → Zone 2)
  From the interactive shell on ansiblectr01, you execute ansible-playbook -i inventory.ini zabbix-deploy.yml. ansiblectr01 acts as the execution bastion and opens an SSH connection (TCP 22) downward into zabbix02 (10.68.20.15) in Zone 2 to push configuration tasks.

* Leg 3: Software Package Pull (Zone 2 → Zone 2.5)
  When Ansible triggers apt install zabbix-proxy-sqlite3 on zabbix02, zabbix02 consults its local proxy file (/etc/apt/apt.conf.d/01proxy) and pulls the required .deb packages outbound from ansiblectr01:3142 (apt-cacher-ng) in Zone 2.5.

* Leg 4: Steady-State Metric Telemetry (Zone 2 → Zone 2.5)
  Once the zabbix-proxy service starts on zabbix02, it initiates stateful outbound connections upward over TCP 10051 to zabbix01 (10.68.68.50) in Zone 2.5 to deliver collected system metrics.


### 4.1 Leg 2 complies with the Purdue Model and IEC 62443 / ISA-95 standards

Leg 2 complies with the Purdue Model and IEC 62443 / ISA-95 standards because the iDMZ (Zone 2.5) serves as a mandatory protocol break and security buffer between enterprise IT (Level 3.5) and Control OT (Zone 2).

* No Multi-Zone Bypass: The Purdue Model explicitly prohibits connections that jump across multiple zones (such as Level 3.5 directly to Zone 2). Level 3.5 traffic terminates at ansiblectr01.
* iDMZ Bastion Function: Zone 2.5 is designed as the designated staging area for administrative control. Traversing downward from Zone 2.5 into Zone 2 over a single, tightly controlled management protocol (SSH TCP 22) is a recognized standard architecture for industrial configuration management.
* Controlled & Audited Conduit: The firewall permits downward traffic strictly from the single source IP of ansiblectr01 to specific target host IPs on port 22/5985, rather than opening blanket access into Zone 2.
* Decoupled Sessions: The SSH session from Level 3.5 to ansiblectr01 and the SSH/WinRM connection from ansiblectr01 to Zone 2 hosts are entirely separate TCP sessions. No direct packet forwarding or routing occurs between Level 3.5 and Zone 2.

### 4.3 Teoretical steps for ansiblectr01

1. Log into ansiblectr01 using the initial credentials provided by the datacenter build team.
2. Configure the static IP address (10.68.68.10) and set the system hostname to ansiblectr01.
3. Generate SSH key pairs to enable automated management across target nodes.
4. Update system package repositories using the whitelisted outbound internet connection.
5. Install necessary core packages (ansible, apt-cacher-ng, apache2, curl, gpg, parted, e2fsprogs, and rsync).
6. Configure apt-cacher-ng to allow HTTPS passthrough (PassThroughPattern: ^.*:443$).
7. Enable and start the apt-cacher-ng and apache2 system services.
8. Download the Windows Zabbix Agent2 .msi installer into the Apache web root directory (/var/www/html/packages/).
9. Install required Ansible Galaxy collections (community.zabbix, ansible.windows, posix, and community.general).
10. Populate the Ansible inventory file (inventory.ini) with the host IP addresses and credentials for zabbix01, mysql01, zabbix02, and the Windows VMs.
11. Stage the deployment and maintenance playbooks (zabbix-deploy.yml, patch-ubuntu.yml, and patch-windows.yml) on the filesystem.
12. Test SSH and WinRM connectivity from ansiblectr01 to all target hosts across Zone 2.5 and Zone 2.

The package distribution mechanism

The package distribution mechanism differs between Linux nodes and Windows VMs for specific technical reasons:

* Linux Nodes (zabbix01, mysql01, zabbix02): Handled on-demand by apt-cacher-ng. 
* When Ansible executes apt install zabbix-server-mysql on zabbix01, apt routes the request through http://ansiblectr01:3142. apt-cacher-ng automatically fetches the required .deb files from repo.zabbix.com or archive.ubuntu.com over ansiblectr01's whitelisted egress, caches them in /var/cache/apt-cacher-ng, and streams them to the target server.

* Windows VMs: Windows Server does not natively integrate with apt or apt-cacher-ng. 
* Ansible's win_package module requires an HTTP endpoint to pull installation media, which is why only the static .msi installer is hosted in Apache at [http://10.68.68.10/packages/zabbix_agent2.msi](http://10.68.68.10/packages/zabbix_agent2.msi).

### 4.4 Step-by-Step Flow: Manual Commands vs. Automated apt-cacher-ng


```txt
[ Manual Online Steps ]                     [ Automated Ansible + apt-cacher-ng Flow ]

 1. wget zabbix-release.deb           ──────>  zabbix01 fetches repository key/list via ansiblectr01:3142
 2. dpkg -i zabbix-release.deb        ──────>  zabbix01 registers repo.zabbix.com in /etc/apt/sources.list.d/
 3. apt update                        ──────>  zabbix01 requests package indexes through ansiblectr01:3142
 4. apt install zabbix-server-mysql   ──────>  apt-cacher-ng downloads & caches the .deb files, then serves zabbix01
```

> [!NOTE] 

🔵 Stage 1: Registering the Zabbix Repository on zabbix01

What zabbix-release...deb actually is: It is not Zabbix Server itself. It is a 10 KB configuration package that contains zabbix.list (the URL pointing to repo.zabbix.com) and the official GPG signing key.

How it routes: When zabbix01 fetches this zabbix-release package, it routes through http://ansiblectr01:3142. ansiblectr01 passes it out to repo.zabbix.com, caches the 10 KB file, and hands it to zabbix01.

🔵 Stage 2: Installing the Actual Software (apt install zabbix-server-mysql ...)

What happens during apt install: zabbix01 reads its newly added zabbix.list file and requests all required .deb dependencies (zabbix-server-mysql, zabbix-frontend-php, zabbix-apache-conf, zabbix-sql-scripts, PHP libraries, MySQL client, etc.).

On-Demand Caching: Instead of you manually downloading dozens of .deb files onto ansiblectr01, zabbix01 simply asks ansiblectr01:3142 for each file as needed. apt-cacher-ng fetches them from repo.zabbix.com over ansiblectr01's whitelisted egress, saves a copy in /var/cache/apt-cacher-ng/, and installs them on zabbix01.


🔵 How Ansible Handles This Automatically in zabbix-deploy.yml

In Ansible, you do not run wget or dpkg -i manually. Ansible automates both stages through ansiblectr01:3142

```yml
# Version: 1.7.0
# Description: Automates Zabbix repository registration and package installation via apt-cacher-ng

- name: Register Zabbix 7.0 LTS Repository and Install Server
  hosts: zabbix_server
  become: true
  tasks:
    - name: Download and install Zabbix repository configuration package via proxy
      ansible.builtin.apt:
        deb: "https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu26.04_all.deb"
        state: present

    - name: Install Zabbix Server, Frontend, and Dependencies
      ansible.builtin.apt:
        name:
          - zabbix-server-mysql
          - zabbix-frontend-php
          - zabbix-apache-conf
          - zabbix-sql-scripts
          - zabbix-agent2
        state: present
        update_cache: yes

```


🔵 Summary Comparison

Windows Agent2: Needs apache2 on ansiblectr01 hosting zabbix_agent2.msi because Windows has no native apt daemon to talk to apt-cacher-ng.

Linux Nodes (zabbix01, mysql01, zabbix02): Use apt-cacher-ng for everything. You add the repository once, and apt dynamically fetches all .deb packages through ansiblectr01 without manual file management.


![topolgy it ot](https://github.com/spawnmarvel/kvm-lab/blob/main/images/topology_io_ot.jpeg)


### GOTO run_research_1_IT-OT_zabbix_stack

GOTO run_research_1_IT-OT_zabbix_stack

or https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_1_IT-OT_zabbix_stack/readme.md


