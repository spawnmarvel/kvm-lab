# Ansible IT/OT zabbix stack poc

Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

## Table of content

- [Ansible](#ansible)
  - [Table of content](#table-of-content)
- [Here's a quick guide to get you up to speed on Ansible](#heres-a-quick-guide-to-get-you-up-to-speed-on-ansible)
  - [Core Concepts](#core-concepts)
  - [Key Advantages](#key-advantages)
  - [Ansible Agentless Architecture Linux and Windows](#ansible-agentless-architecture-linux-and-windows)
- [Install Ansible on host Ubuntu 26.04](#install-ansible-on-host-ubuntu-2604)
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

## Getting started with Ansible GOTO tutorial_ansible

Do a new recap of the tutorial so you are up to speed.

This must be done before you start.

GOTO ansible/tutorial_ansible


# Proof of Concept (PoC) Operational Runbook

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


## 2. Phase 1: Host Virtualization & Isolated Network Configuration

Before deploying the target stack, isolated virtual networks must be established on the physical host to separate the iDMZ (Zone 2.5) from the OT Control network (Zone 2) while designating ansiblectr01 as the sole gateway.

## 3. Phase 2: Guest Image Staging and Volume Provisioning

Deploy the VM disk files and provision the secondary 60GB disk volume datadrive1 designated for mysql01 database use.

## 4. Phase 3: Bootstrap and Automation Execution

With the target hosts running, ansiblectr01 acts as the single egress point to fetch dependencies and distribute updates internally.

## 5. Phase 4: Validation and Compliance Assurance

Ensure the deployment meets your strict security goals before handing over the system for monitoring:


# Run Proof of Concept (PoC) Operational Runbook


