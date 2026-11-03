# Ansible IT/OT zabbix stack poc

Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

## Table of content

- [Ansible IT/OT zabbix stack poc](#ansible-itot-zabbix-stack-poc)
  - [Table of content](#table-of-content)
- [Here's a quick guide to get you up to speed on Ansible](#heres-a-quick-guide-to-get-you-up-to-speed-on-ansible)
  - [Core Concepts](#core-concepts)
  - [Key Advantages](#key-advantages)
  - [Ansible Agentless Architecture Linux and Windows](#ansible-agentless-architecture-linux-and-windows)
- [Install Ansible on hostkvm-host-HP-ProDesk-600-G3-SFF Ubuntu 26.04](#install-ansible-on-hostkvm-host-hp-prodesk-600-g3-sff-ubuntu-2604)
  - [Getting started with Ansible](#getting-started-with-ansible)
- [Proof of Concept (PoC) Operational Runbook](#proof-of-concept-poc-operational-runbook)
  - [Topology](#topology)
  - [1. Environment and Tools Baseline](#1-environment-and-tools-baseline)
  - [1.1 Scenario \& Core Requirements Summary from research](#11-scenario--core-requirements-summary-from-research)
  - [2. Phase 1: Host Virtualization \& Isolated Network Configuration](#2-phase-1-host-virtualization--isolated-network-configuration)
    - [1. Zone 2.5 iDMZ Network Definition (zone25-idmz.xml)](#1-zone-25-idmz-network-definition-zone25-idmzxml)
    - [2. Zone 2 OT Control Network Definition (zone2-ot.xml)](#2-zone-2-ot-control-network-definition-zone2-otxml)
  - [3. Phase 2: Guest Image Staging and Volume Provisioning](#3-phase-2-guest-image-staging-and-volume-provisioning)
    - [Create disks](#create-disks)
    - [Deploy vms](#deploy-vms)
    - [Verify vms](#verify-vms)
    - [Use all full disk](#use-all-full-disk)
    - [View zones](#view-zones)
    - [Auto boot](#auto-boot)
    - [4 vms](#4-vms)
  - [4. Phase 3: Bootstrap and Automation Execution](#4-phase-3-bootstrap-and-automation-execution)
  - [5. Phase 4: Validation and Compliance Assurance](#5-phase-4-validation-and-compliance-assurance)
- [Run Proof of Concept (PoC) Operational Runbook](#run-proof-of-concept-poc-operational-runbook)
  - [1. Inventory](#1-inventory)
  - [2. SSH key-based authentication](#2-ssh-key-based-authentication)
  - [3. Ansible Ad-hoc commands](#3-ansible-ad-hoc-commands)
  - [4. Playbooks](#4-playbooks)
    - [4.1 Make tracking folder](#41-make-tracking-folder)
    - [4.2 Install MySQL](#42-install-mysql)
    - [4.3 Install Zabbix](#43-install-zabbix)
    - [4.4 Install Zabbix proxy](#44-install-zabbix-proxy)

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


# Install Ansible on hostkvm-host-HP-ProDesk-600-G3-SFF Ubuntu 26.04 

```bash
# install all
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# verify all
ansible --version

ansible [core 2.21.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/espenk/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/espenk/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.14.4 (main, Aug 20 2026, 10:41:58) [GCC 15.2.0] (/usr/bin/python3)
  jinja version = 3.1.6
  pyyaml version = 6.0.3 (with libyaml v0.2.5)

```

Installing Ansible on Ubuntu

Ubuntu provides Ansible packages through a Personal Package Archive (PPA) that contains more recent versions than the standard repositories.

https://docs.ansible.com/projects/ansible/latest/installation_guide/installation_distros.html

## Getting started with Ansible

Do a new recap of the tutorial so you are up to speed.

This must be done before you start.

GOTO ansible/tutorial_ansible or use and build the quickguide as we walk. /ansible_quickguide.md


# Proof of Concept (PoC) Operational Runbook

## Topology

![topolgy it ot](https://github.com/spawnmarvel/kvm-lab/blob/main/images/topology_io_ot2.jpeg)

## 1. Environment and Tools Baseline

This PoC runs on an HP ProDesk 600 G3 SFF functioning as the virtualization node:

Physical Host: kvm-host-HP-ProDesk-600-G3-SFF

Operating System: Linux 7.0.0-42-generic #42-Ubuntu SMP PREEMPT_DYNAMIC (x86_64)

Processor: Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz (8 vCPUs)

System Memory: 24 GB DDR4 RAM

Hypervisor Stack:

virsh (libvirt) version: 12.0.0

API version: QEMU 12.0.0

Hypervisor: QEMU 10.2.1

Internet Status: The physical host has no outbound firewall restrictions, allowing it to host and pull base images and tool dependencies. However, VM-level routing will enforce a single egress path on ansiblectr01 to ensure a realistic Purdue model simulation.


## 1.1 Scenario & Core Requirements Summary from research

Datacenter Handover: The datacenter build team manually provisions clean Ubuntu 26.04 and Windows Server VMs via GUI. Day-2 automation begins immediately after IP and credential handover.

1. Scenario & Core Requirements Summary
2. Why apt-cacher-ng Was Selected
3. Firewall Rule Matrix (Purdue / ISA-95 Architecture)

https://github.com/spawnmarvel/kvm-lab/blob/main/research_1_IT-OT_zabbix_stack/readme.md#1-scenario--core-requirements-summary

## 2. Phase 1: Host Virtualization & Isolated Network Configuration

Before deploying the target stack, isolated virtual networks must be established on the physical host to separate the iDMZ (Zone 2.5) from the OT Control network (Zone 2) while designating ansiblectr01 as the sole gateway.

For Phase 1 network setup on kvm-host, here are the complete configuration files and execution commands to deploy both libvirt networks (zone25-idmz and zone2-ot) directly.

### 1. Zone 2.5 iDMZ Network Definition (zone25-idmz.xml)

This network enables NAT forwarding to allow ansiblectr01 outbound internet access while serving as the gateway for Zone 2.5 hosts.

```xml
<!-- Version: 1.0.0 -->
<!-- Description: Libvirt XML definition for Zone 2.5 iDMZ network with NAT forwarding -->
<network>
  <name>zone25-idmz</name>
  <forward mode='nat'/>
  <bridge name='virbr25' state='unknown'/>
  <ip address='10.68.68.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.68.68.100' end='10.68.68.200'/>
    </dhcp>
  </ip>
</network>
```


![net_nat](https://github.com/spawnmarvel/kvm-lab/blob/main/images/net_nat.png)

### 2. Zone 2 OT Control Network Definition (zone2-ot.xml)

This network omits the <forward> tag entirely, creating a strictly isolated internal bridge to enforce air-gapped Purdue Zone 2 requirements.

```xml
<!-- Version: 1.0.0 -->
<!-- Description: Libvirt XML definition for Zone 2 OT network in isolated mode without host NAT -->
<network>
  <name>zone2-ot</name>
  <bridge name='virbr20' state='unknown'/>
  <ip address='10.68.20.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.68.20.100' end='10.68.20.200'/>
    </dhcp>
  </ip>
</network>
```

![net_iso](https://github.com/spawnmarvel/kvm-lab/blob/main/images/net_iso.png)

```bash
ssh espenk@192.168.10.70
mkdir io_ot_lab_build
sudo nano create_network.sh
bash create_network.sh

```

Log

```log
Network zone25-idmz defined from zone25-idmz.xml

Network zone25-idmz started

Network zone25-idmz marked as autostarted

Network zone2-ot defined from zone2-ot.xml

Network zone2-ot started

Network zone2-ot marked as autostarted
```

List

```bash
sudo virsh net-list --all
Name          State    Autostart   Persistent
------------------------------------------------
zone2-ot      active   yes         yes
zone25-idmz   active   yes         yes
```

## 3. Phase 2: Guest Image Staging and Volume Provisioning

Deploy the VM disk files and provision the secondary 30 GB disk volume datadrive1 designated for mysql01 database use, we do not mount it before day 2 with ansible.

Resource Allocation Summary

* ansiblectr01: 2 vCPU, 4 GB RAM (Zone 2.5 iDMZ)
* zabbix01: 2 vCPU, 3 GB RAM (Zone 2.5 iDMZ)
* mysql01: 2 vCPU, 3 GB RAM (Zone 2.5 iDMZ)
* zabbix02: 2 vCPU, 3 GB RAM (Zone 2 OT Proxy)



### Create disks

```bash
sudo nano create_disks.sh
bash create_disks.sh
Formatting '/mnt/datadrive1/qemu/images/ansiblectr01.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=21474836480 lazy_refcounts=off refcount_bits=16
Formatting '/mnt/datadrive1/qemu/images/zabbix01.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=21474836480 lazy_refcounts=off refcount_bits=16
Formatting '/mnt/datadrive1/qemu/images/mysql01.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=21474836480 lazy_refcounts=off refcount_bits=16
Formatting '/mnt/datadrive1/qemu/images/zabbix02.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=21474836480 lazy_refcounts=off refcount_bits=16
Formatting '/mnt/datadrive1/qemu/images/mysql01-datadrive1.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=32212254720 lazy_refcounts=off refcount_bits=16
```

List iso

```bash
sudo virsh pool-list --all
Name              State    Autostart
---------------------------------------
boot              active   yes
datadrive1-pool   active   yes
default           active   yes

for pool in $(sudo virsh pool-list --all --name | grep -v '^$'); do
    echo "=== Storage Pool: ${pool} ==="
    sudo virsh vol-list "${pool}"
done
```

Log

```txt
=== Storage Pool: boot ===
 Name   Path
--------------

=== Storage Pool: datadrive1-pool ===
 Name                           Path
------------------------------------------------------------------------------
 iso                            /mnt/datadrive1/iso
 lost+found                     /mnt/datadrive1/lost+found
 SERVER_EVAL_x64FRE_en-us.iso   /mnt/datadrive1/SERVER_EVAL_x64FRE_en-us.iso
 vms                            /mnt/datadrive1/vms

=== Storage Pool: default ===
 Name                      Path
----------------------------------------------------------------------------
 debian-12-netinst.iso     /var/lib/libvirt/images/debian-12-netinst.iso
 ubuntu-26.04-server.iso   /var/lib/libvirt/images/ubuntu-26.04-server.iso
```

### Deploy vms

| Hostname       | Network     | IP Address  | MAC Address       | Memory / vCPU | Primary / Secondary Storage                            |
| -------------- | ----------- | ----------- | ----------------- | ------------- | ------------------------------------------------------ |
| `ansiblectr01` | zone25-idmz | 10.68.68.10 | 52:54:00:68:68:10 | 4 GB / 2 vCPU | ansiblectr01.qcow2 (20GB)                              |
| `zabbix01`     | zone25-idmz | 10.68.68.50 | 52:54:00:68:68:50 | 3 GB / 2 vCPU | zabbix01.qcow2 (20GB)                                  |
| `mysql01`      | zone25-idmz | 10.68.68.52 | 52:54:00:68:68:52 | 3 GB / 2 vCPU | mysql01.qcow2 (20GB) + mysql01-datadrive1.qcow2 (30GB) |
| `zabbix02`     | zone2-ot    | 10.68.20.15 | 52:54:00:68:20:15 | 3 GB / 2 vCPU | zabbix02.qcow2 (20GB)                                  |

* 1 GB: $1 x 1024 = 1024 MB
* 2 GB: $2 x 1024 = 2048 MB
* 3 GB: $3 x 1024 = 3072 MB
* 4 GB: $4 x 1024 = 4096 MB


```bash

sudo nano create_vms_static_ansiblectr01.sh
bash create_vms_static_ansiblectr01.sh

ssh master@10.68.68.10
# master@ansiblectr01:~$

sudo nano create_vms_static_zabbix01.sh
bash create_vms_static_zabbix01.sh

ssh master@10.68.68.50
# master@zabbix01:~$

sudo nano create_vms_static_mysql01.sh
bash create_vms_static_mysql01.sh

# The standard solution is to install Ubuntu with only the primary OS disk attached, 
# verify SSH access, and then attach the secondary 30 GB volume to the domain.

# Attach Secondary Data Disk to Domain, Attach the 30 GB volume to mysql01 as persistent virtual target vdb:
# Version: 1.0.0
# Description: Attaches secondary 30GB qcow2 volume to running mysql01 instance and updates libvirt XML configuration
sudo virsh attach-disk mysql01 /mnt/datadrive1/qemu/images/mysql01-datadrive1.qcow2 vdb --config --live --subdriver qcow2

Disk attached successfully

ssh master@10.68.68.52
#master@mysql01:~$

# Running lsblk inside mysql01 via SSH shows /dev/vda (20G) and /dev/vdb (30G).
lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                        11:0    1 1024M  1 rom
vda                       253:0    0   20G  0 disk
├─vda1                    253:1    0    1M  0 part
├─vda2                    253:2    0  1.8G  0 part /boot
└─vda3                    253:3    0 18.2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   10G  0 lvm  /
vdb                       253:16   0   30G  0 disk

sudo nano create_vms_static_zabbix02.sh
bash create_vms_static_zabbix02.sh

ssh master@10.68.20.15

```

5 minutes per VM is a very accurate estimate for stepping through the interactive Ubuntu Server installer over the serial console.

VM 1 (10.68.68.10 — Zone 2.5 iDMZ): 💥
* Your server's name: ansiblectr01
* Pick a username: master, justfortest

VM 2 (10.68.68.50 — Zone 2.5 iDMZ): 💥
* Your server's name: zabbix01
* Pick a username: master, justfortest

VM 3 (10.68.68.52 — Zone 2.5 iDMZ): 💥
* Your server's name: mysql01
Pick a username: master, justfortest

VM 4 (10.68.20.15 — Zone 2 OT): 💥
* Your server's name: zabbix02
* Pick a username: master, justfortest

### Verify vms

```bash
sudo virsh list
Id   Name           State
------------------------------
2    ansiblectr01   running
4    zabbix01       running
6    mysql01        running

```

![ot install](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ot_install_1.png)


### Use all full disk


```bash

ssh master@10.68.68.10
# master@ansiblectr01:~$

sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv -r
df -h /
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   18G  4.9G   13G  29% /

ssh master@10.68.68.50
# master@zabbix01:~$

sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv -r
df -h /
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   18G  4.9G   13G  29% /

ssh master@10.68.68.52
#master@mysql01:~$

sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv -r
df -h /
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   18G  4.9G   13G  29% 

ssh master@10.68.20.15
# master@zabbix02:~$
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv -r
df -h /
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   18G  4.5G   13G  27% /

```

### View zones

```bash

# Version: 1.0.0
# Description: Checks active DHCP lease status for ansiblectr01 on zone25-idmz
sudo virsh net-dhcp-leases zone25-idmz
Expiry Time           MAC address         Protocol   IP address       Hostname       Client ID or DUID
------------------------------------------------------------------------------------------------------------------------------------------------
2026-11-03 10:11:58   52:54:00:68:68:10   ipv4       10.68.68.10/24   ansiblectr01   ff:56:50:4d:98:00:02:00:00:ab:11:20:72:90:ca:5c:97:66:1e
2026-11-03 10:11:56   52:54:00:68:68:50   ipv4       10.68.68.50/24   zabbix01       ff:56:50:4d:98:00:02:00:00:ab:11:96:a3:ef:6e:d9:63:3e:e1
2026-11-03 10:12:08   52:54:00:68:68:52   ipv4       10.68.68.52/24   mysql01        ff:56:50:4d:98:00:02:00:00:ab:11:29:c1:56:8b:ac:65:be:0f


sudo virsh net-dhcp-leases zone2-ot
Expiry Time           MAC address         Protocol   IP address       Hostname   Client ID or DUID
--------------------------------------------------------------------------------------------------------------------------------------------
2026-11-03 09:11:55   52:54:00:68:20:15   ipv4       10.68.20.15/24   zabbix02   ff:56:50:4d:98:00:02:00:00:ab:11:5a:12:e9:9d:3a:a0:68:ee

```

### Auto boot

```bash
# Version: 1.0.0
# Description: Restarts libvirt service and verifies network bridge states
sudo systemctl restart libvirtd
sudo virsh net-start zone25-idmz 2>/dev/null || true
sudo virsh net-start zone2-ot 2>/dev/null || true
sudo virsh net-list --all

```
Verification: Networks zone25-idmz and zone2-ot show Active: yes

```bash
# Version: 1.0.0
# Description: Configures libvirt autostart policy across all scenario VMs
sudo virsh autostart ansiblectr01
sudo virsh autostart zabbix01
sudo virsh autostart mysql01
sudo virsh autostart zabbix02
```

Verify vms
```bash
sudo virsh list
Id   Name           State
------------------------------
14   zabbix02       running
15   zabbix01       running
16   mysql01        running
19   ansiblectr01   running
```

### 4 vms

![4_vms](https://github.com/spawnmarvel/kvm-lab/blob/main/images/4vms.png)

## 4. Phase 3: Bootstrap and Automation Execution

With the target hosts running, ansiblectr01 acts as the single egress point to fetch dependencies and distribute updates internally.

## 5. Phase 4: Validation and Compliance Assurance

Ensure the deployment meets your strict security goals before handing over the system for monitoring:


# Run Proof of Concept (PoC) Operational Runbook

## 1. Inventory

```bash
ssh espenk@192.168.10.70
mkdir mkdir io_ot_lab_build
```

## 2. SSH key-based authentication

## 3. Ansible Ad-hoc commands

## 4. Playbooks

### 4.1 Make tracking folder

### 4.2 Install MySQL

### 4.3 Install Zabbix

### 4.4 Install Zabbix proxy


