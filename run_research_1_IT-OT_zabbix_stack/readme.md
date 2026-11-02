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
  - [4. Phase 3: Bootstrap and Automation Execution](#4-phase-3-bootstrap-and-automation-execution)
  - [5. Phase 4: Validation and Compliance Assurance](#5-phase-4-validation-and-compliance-assurance)
- [Run Proof of Concept (PoC) Operational Runbook](#run-proof-of-concept-poc-operational-runbook)

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


```bash
ssh espenk@192.168.10.70
mkdir io_ot_lab
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
* zabbix02: 2 vCPU, 2 GB RAM (Zone 2 OT Proxy)



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
| `zabbix02`     | zone2-ot    | 10.68.20.15 | 52:54:00:68:20:15 | 2 GB / 2 vCPU | zabbix02.qcow2 (20GB)                                  |


```bash

sudo nano create_vms_static.sh
bash create_vms_static.sh

```

5 minutes per VM is a very accurate estimate for stepping through the interactive Ubuntu Server installer over the serial console.

VM 1 (10.68.68.10 — Zone 2.5 iDMZ): 💥
* Your server's name: ansiblectr01
* Pick a username: master, justfortest

VM 2 (10.68.68.50 — Zone 2.5 iDMZ):
* Your server's name: zabbix01
* Pick a username: master, justfortest

VM 3 (10.68.68.52 — Zone 2.5 iDMZ):
* Your server's name: mysql01
Pick a username: master, justfortest

VM 4 (10.68.20.15 — Zone 2 OT):
* Your server's name: zabbix02
* Pick a username: master, justfortest

## 4. Phase 3: Bootstrap and Automation Execution

With the target hosts running, ansiblectr01 acts as the single egress point to fetch dependencies and distribute updates internally.

## 5. Phase 4: Validation and Compliance Assurance

Ensure the deployment meets your strict security goals before handing over the system for monitoring:


# Run Proof of Concept (PoC) Operational Runbook


