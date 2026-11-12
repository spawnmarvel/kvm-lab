# Ansible stack in Azure

Do the same as with KVM, Kernel Virtual Machine for repetions and demo online.


## Table of content
- [Ansible stack in Azure](#ansible-stack-in-azure)
  - [Table of content](#table-of-content)
- [Introduction](#introduction)
  - [Scenario](#scenario)
  - [Team 1](#team-1)
  - [Team 2 starts with ansiblectr01](#team-2-starts-with-ansiblectr01)
- [1. Topology](#1-topology)
- [Ansible](#ansible)
    - [Ansible idempotent](#ansible-idempotent)
    - [Ansible cheat sheet](#ansible-cheat-sheet)
    - [Ansible quick guide](#ansible-quick-guide)
    - [Ansible and Red Hat](#ansible-and-red-hat)
      - [Official Ansible Documentation Portal](#official-ansible-documentation-portal)
      - [Ansible provides open-source automation that reduces complexity and runs everywhere.](#ansible-provides-open-source-automation-that-reduces-complexity-and-runs-everywhere)
      - [Introduction to Ansible Guide: Ansible Introduction \& Use Cases](#introduction-to-ansible-guide-ansible-introduction--use-cases)
      - [Red Hat Ansible Automation Platform Overview:](#red-hat-ansible-automation-platform-overview)
      - [This module is able to configure a FortiGate or FortiOS (FOS) device](#this-module-is-able-to-configure-a-fortigate-or-fortios-fos-device)
      - [Ansible Network Examples](#ansible-network-examples)
      - [Ansible can configure and manage network switches from a wide variety of hardware vendors using specialized](#ansible-can-configure-and-manage-network-switches-from-a-wide-variety-of-hardware-vendors-using-specialized)
      - [Ansible can configure, provision, and manage several major hypervisors and virtualization platforms](#ansible-can-configure-provision-and-manage-several-major-hypervisors-and-virtualization-platforms)
- [Back to scenario](#back-to-scenario)
  - [Firewal and practical information](#firewal-and-practical-information)
  - [Whitelisted repo for ansiblectr01](#whitelisted-repo-for-ansiblectr01)
  - [Firewall Rule Matrix (Purdue / ISA-95 Architecture)](#firewall-rule-matrix-purdue--isa-95-architecture)
  - [Vnet and subnet](#vnet-and-subnet)
  - [VM's Azure Retirement of default outbound access: scope and impact](#vms-azure-retirement-of-default-outbound-access-scope-and-impact)
  - [Virtual machines in Rg-swc-ansiblestack-01](#virtual-machines-in-rg-swc-ansiblestack-01)
  - [Virtual machines in Rg-swc-vms-01](#virtual-machines-in-rg-swc-vms-01)
- [Ansible configuration](#ansible-configuration)
  - [Create ansiblectr01 Subnet 1 (iDMZ / Management)](#create-ansiblectr01-subnet-1-idmz--management)
  - [Install Ansible on ansiblectr01](#install-ansible-on-ansiblectr01)
    - [Create folder structure](#create-folder-structure)
  - [Create zabbix01 Subnet 1 (iDMZ / Management)](#create-zabbix01-subnet-1-idmz--management)
  - [Populate folder structure and verify ssh](#populate-folder-structure-and-verify-ssh)
    - [Enable passwordless, secure SSH authentication and log on ansiblectr01 in /opt/ansible](#enable-passwordless-secure-ssh-authentication-and-log-on-ansiblectr01-in-optansible)
  - [Playbook linux ping\_hosts.yml](#playbook-linux-ping_hostsyml)
  - [Set up apt-cacher-ng and Apache on ansiblectr01](#set-up-apt-cacher-ng-and-apache-on-ansiblectr01)
    - [Allowed remote repositories](#allowed-remote-repositories)
  - [Playbook linux configure\_apt\_proxy.yml](#playbook-linux-configure_apt_proxyyml)
    - [Veriy manual update on zabbix01](#veriy-manual-update-on-zabbix01)
  - [Playbook linux update\_apt.yml with callbacks\_enabled = profile\_tasks, timer](#playbook-linux-update_aptyml-with-callbacks_enabled--profile_tasks-timer)
  - [Current vms](#current-vms)
- [Semaphore UI](#semaphore-ui)
  - [Install Semaphore UI on ansiblectr01](#install-semaphore-ui-on-ansiblectr01)
    - [We could do it with Ansible playbook also/ this is manual install to get to know it](#we-could-do-it-with-ansible-playbook-also-this-is-manual-install-to-get-to-know-it)
    - [Accessing Semaphore UI](#accessing-semaphore-ui)
    - [SSL/TLS Certificates](#ssltls-certificates)
    - [Apache in front of Semaphore for secure HTTPS access](#apache-in-front-of-semaphore-for-secure-https-access)
  - [Setup Ansible ansiblectr01 with Semaphore](#setup-ansible-ansiblectr01-with-semaphore)
  - [Playbooks linux Semaphore run](#playbooks-linux-semaphore-run)
    - [linux ping\_hosts.yml](#linux-ping_hostsyml)
    - [linux update\_apt.yml](#linux-update_aptyml)
- [2. Topology at this stage](#2-topology-at-this-stage)
- [Set up the rest of the stack](#set-up-the-rest-of-the-stack)
  - [Create mysql01 and zabbix02](#create-mysql01-and-zabbix02)
  - [No outbound to internet](#no-outbound-to-internet)
  - [Structure inventory/hosts.ini and align all configurations](#structure-inventoryhostsini-and-align-all-configurations)
    - [Add ssh keys for new hosts](#add-ssh-keys-for-new-hosts)
    - [Playbook linux yml update hosts and verify current templates](#playbook-linux-yml-update-hosts-and-verify-current-templates)
  - [Run linux ping\_hosts.yml Semaphore](#run-linux-ping_hostsyml-semaphore)
    - [Playbook Linux verify\_isolation.yml](#playbook-linux-verify_isolationyml)
    - [Playbook Linux configure\_apt\_proxy.yml](#playbook-linux-configure_apt_proxyyml-1)
    - [Playbook Linux update\_apt.yml patch all hosts with one click](#playbook-linux-update_aptyml-patch-all-hosts-with-one-click)
  - [Playbook Configure a Dedicated Template per Host/Group (Recommended) in Semaphore](#playbook-configure-a-dedicated-template-per-hostgroup-recommended-in-semaphore)
  - [Semaphore statistic](#semaphore-statistic)
- [Playbooks with Ansible (Now we can really start)](#playbooks-with-ansible-now-we-can-really-start)
- [3. Topology at this stage](#3-topology-at-this-stage)
  - [Update inventory/host.ini](#update-inventoryhostini)
  - [Playbook get\_linux\_version.yml](#playbook-get_linux_versionyml)
  - [Playbook linux mount\_datadrive\_check.yml --check --limit](#playbook-linux-mount_datadrive_checkyml---check---limit)
  - [Playbook linux mount\_datadrive.yml](#playbook-linux-mount_datadriveyml)
  - [Playbook linux tbd.yml](#playbook-linux-tbdyml)
- [Create a Windows host](#create-a-windows-host)
  - [Playbook windows tbd](#playbook-windows-tbd)


# Introduction

## Scenario

1. Day 1: Team 1 build infrastucture and data center.
2. Day 2 to day 3: Team 2 install monitoring stack with Ansible
3. Day 3 to day n: Team 2 automate install, update and support operations with ansible.

Datacenter Handover: The datacenter build team manually provisions clean Ubuntu 26.04 and Windows Server VMs via GUI. 

Day-2 automation begins immediately after IP and credential handover, set up stack with Ansible.

## Team 1

![haha_2](https://github.com/spawnmarvel/kvm-lab/blob/main/images/haha_2.png)

## Team 2 starts with ansiblectr01

![haha](https://github.com/spawnmarvel/kvm-lab/blob/main/images/haha.png)

# 1. Topology

This is the final set up (ip may change but the concept is the same)

![topology](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/topology.png)

# Ansible

![ansible1](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/ansible1.png)

https://docs.ansible.com/projects/ansible/latest/getting_started/index.html

### Ansible idempotent

Yes, Ansible is idempotent by design when using its built-in modules, meaning you can run a playbook multiple times without changing the system after the first run unless the desired state change

### Ansible cheat sheet

https://github.com/spawnmarvel/kvm-lab/blob/main/ansible_cheat_sheet.pdf

### Ansible quick guide

The quick guide will also be updated as we go.

https://github.com/spawnmarvel/kvm-lab/blob/main/ansible_quickguide.md


### Ansible and Red Hat


![ansible_circle](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/ansible_circle.png)


#### Official Ansible Documentation Portal

The primary hub for getting started, understanding core concepts (inventories, playbooks, modules), and managing managed nodes.

https://docs.ansible.com/


#### Ansible provides open-source automation that reduces complexity and runs everywhere.

https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html

#### Introduction to Ansible Guide: Ansible Introduction & Use Cases

Covers the foundational design principles (agentless architecture, idempotency, and supported workflows).

https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html


#### Red Hat Ansible Automation Platform Overview:


Details enterprise-grade execution, multi-vendor network automation, cloud provisioning, and orchestration features.

https://www.redhat.com/en/technologies/management/ansible

#### This module is able to configure a FortiGate or FortiOS (FOS) device

This module is able to configure a FortiGate or FortiOS (FOS) device by allowing the user to set and modify system feature and interface category. Examples include all parameters and values need to be adjusted to datasources before usage. Tested with FOS v6.0.0

https://docs.ansible.com/projects/ansible/latest/collections/fortinet/fortios/fortios_system_interface_module.html


#### Ansible Network Examples

This document describes some examples of using Ansible to manage your network infrastructure.

https://docs.ansible.com/projects/ansible/latest/network/user_guide/network_best_practices_2.5.html

#### Ansible can configure and manage network switches from a wide variety of hardware vendors using specialized


Major Supported Switch Platforms

| Vendor / Platform Family | Operating System & Edition               | Ansible Collection / Module Namespace |
| :----------------------- | :--------------------------------------- | :------------------------------------ |
| **Cisco**                | Cisco IOS / IOS-XE                       | `cisco.ios`                           |
| **Cisco**                | Cisco NX-OS (Nexus)                      | `cisco.nxos`                          |
| **Cisco**                | Cisco IOS-XR                             | `cisco.iosxr`                         |
| **Cisco**                | Cisco Meraki                             | `cisco.meraki`                        |
| **Arista**               | Arista EOS                               | `arista.eos`                          |
| **Juniper**              | Juniper Junos OS                         | `junipernetworks.junos`               |
| **Dell**                 | Dell OS6, OS9, OS10 (PowerSwitch)        | `dell.os6`, `dell.os9`, `dell.os10`   |
| **Aruba / HP**           | Aruba, ProCurve, Comware                 | Community and vendor modules          |
| **Other Vendors**        | VyOS                                     | `vyos.vyos`                           |
| **Other Vendors**        | Nokia SR OS                              | `nokia.sros`                          |
| **Other Vendors**        | Extreme Networks, Huawei, MikroTik, etc. | EXOS, VOSS, CloudEngine, RouterOS     |


https://docs.ansible.com/projects/ansible/latest/collections/index.html


#### Ansible can configure, provision, and manage several major hypervisors and virtualization platforms

Ansible can configure, provision, and manage several major hypervisors and virtualization platforms using official or community-supported Ansible collections.


Supported and Configurable Hypervisors

| Hypervisor / Cloud Platform                          | Ansible Collection                                                                         | Core Capabilities & Management Features                                                                                             |
| :--------------------------------------------------- | :----------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| **VMware (vSphere / ESXi / vCenter)**                | `community.vmware` (or certified `vmware.vmware` / `vmware.ansible_vcenter_plugin` suites) | Provision, clone, power on/off, reconfigure VMs, manage datastores, networks, and dynamic inventories                               |
| **Proxmox VE (Virtual Environment)**                 | `community.proxmox`                                                                        | Create, start, stop, delete, and configure KVM virtual machines and LXC containers                                                  |
| **Microsoft Hyper-V & SCVMM**                        | `microsoft.hyperv` and `microsoft.scvmm`                                                   | Provision VMs, manage virtual processors, memory, network adapters, and Windows-specific guest configurations via PowerShell Direct |
| **KVM / Libvirt (Linux Kernel-based VM)**            | `community.libvirt` (e.g., `community.libvirt.virt_install`)                               | Declare and provision virtual machines via libvirt and qemu                                                                         |
| **Amazon EC2 / Cloud Hypervisors (AWS, Azure, GCP)** | `amazon.aws`, `azure.azcollection`, `google.cloud`                                         | Manage cloud-native instances running on underlying hypervisor fleets                                                               |

You can browse and install these modules via the Ansible Community Documentation Index or Ansible Galaxy.

Ansible Community Documentation

https://docs.ansible.com/projects/ansible/latest/collections/index.html

Ansible Galaxy

https://galaxy.ansible.com/ui/





# Back to scenario

## Firewal and practical information

## Whitelisted repo for ansiblectr01

| Rule ID    | Source Host    | Source Zone     | Destination FQDN / Host                          | Destination Zone    | Protocol / Port | Purpose                                                            |
| :--------- | :------------- | :-------------- | :----------------------------------------------- | :------------------ | :-------------- | :----------------------------------------------------------------- |
| **FW-01a** | `ansiblectr01` | Zone 2.5 (iDMZ) | `archive.ubuntu.com`, `security.ubuntu.com`      | External / Internet | TCP 80, 443     | Ubuntu base OS packages, security patches, and system dependencies |
| **FW-01b** | `ansiblectr01` | Zone 2.5 (iDMZ) | `ppa.launchpadcontent.net`, `galaxy.ansible.com` | External / Internet | TCP 80, 443     | Ansible PPA repository and Ansible Galaxy collection access        |
| **FW-01c** | `ansiblectr01` | Zone 2.5 (iDMZ) | `repo.zabbix.com`                                | External / Internet | TCP 80, 443     | Zabbix official repository and package updates                     |

## Firewall Rule Matrix (Purdue / ISA-95 Architecture)

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

Read more if needed:

* https://github.com/spawnmarvel/kvm-lab/blob/main/research_1_IT-OT_zabbix_stack/firewall_rule_matrix.md


## Vnet and subnet

Zone 1: External access public ip

Subnet 1 (iDMZ / Management) zone 2.5:

Address range: 10.68.68.0/24

Covers: 10.68.68.4 (ansiblectr01), 10.68.68.5 (zabbix01), and ip tbd (mysql01).

Subnet 2 (OT / Target) zone 2.0:

Address range: 10.68.20.0/24

Covers: ip tbd (zabbix02)


![vnet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vnet.png)

## VM's Azure Retirement of default outbound access: scope and impact

That is correct. Microsoft has shifted default outbound access to restricted/disabled for new virtual machines in Azure.

When a VM does not have explicit outbound connectivity configured—such as through an Azure NAT Gateway, a load balancer with outbound rules, or an explicit public IP with outbound rules configured under the newer security models—it cannot initiate outbound connections to the public internet.

Opening port 8080, 80, and 443 with source "Any" and destination "Any" via a Network Security Group (NSG) rule would bypass your internal caching architecture and expose your nodes directly to the public internet.

Only your controller node (ansiblectr01 at 10.68.68.4) needs direct internet access to pull fresh packages from the public repositories and cache them via apt-cacher-ng.

Adding a public IP address to zabbix01 allows you to access the Zabbix web interface from your browser while keeping outbound internet access blocked via your Network Security Group (NSG) rules.

Yes, exactly. Under Azure's default outbound access policy, assigning a public IP address to a virtual machine (such as zabbix01) does not automatically grant it outbound internet access.

https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access?tabs=portal

## Virtual machines in Rg-swc-ansiblestack-01

* ansiblectr01, 10.68.68.4, with public ip and allow internet
* azureuser/ ouch no-> imsdal, you know


## Virtual machines in Rg-swc-vms-01

* zabbix01, 10.68.68.5, (with public ip also, but no outbund internet, deny with NSG) later
* mysql01, 10.68.68.52, no outbund internet by default
* zabbix02, 10.68.20.15, no outbund internet by default


# Ansible configuration

## Create ansiblectr01 Subnet 1 (iDMZ / Management)

![ansible](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/ansiblectr01.png)

## Install Ansible on ansiblectr01


ansiblectr01 | Network settings Outbund port rule added

Allow_internet

![nsg inet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/nsg_inet.png)

10.68.68.4

```bash

azureuser@ansiblectr01

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# install
sudo apt install ansible

# check v
ansible --version
```
Log

```console
ansible [core 2.21.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/azureuser/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/azureuser/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.14.4 (main, Aug 20 2026, 10:41:58) [GCC 15.2.0] (/usr/bin/python3)
  jinja version = 3.1.6
  pyyaml version = 6.0.3 (with libyaml v0.2.5)
```

https://docs.ansible.com/projects/ansible/latest/installation_guide/installation_distros.html

### Create folder structure

```bash
mkdir io_ot_lab
cd io_ot_lab
mkdir inventory
cd inventory
touch hosts.ini
cd..
mkdir playbooks
touch ansible.cfg

ls
ansible.cfg  inventory  playbooks
```


## Create zabbix01 Subnet 1 (iDMZ / Management)

10.68.68.5

```bash
# ssh into vm
Last login: Wed Nov 11 18:25:27 2026 from 10.68.68.4
azureuser@zabbix01
```

![zabbix01](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/zabbix01.png)

## Populate folder structure and verify ssh

```bash

azureuser@ansiblectr01

cd io_ot_lab/

sudo nano inventory/hosts.ini
```

Configure inventory/hosts.ini

```ini
[ot_nodes]
zabbix01 ansible_host=10.68.68.5 ansible_user=azureuser

[ot_nodes:vars]
ansible_connection=ssh
```

```bash
ansible-inventory -i inventory/hosts.ini --list
```
Verification: Run ansible-inventory -i inventory/hosts.ini --list to ensure Ansible parses the host definition correctly.

```console
azureuser@ansiblectr01:~/io_ot_lab$ ansible-inventory -i inventory/hosts.ini --list
{
    "_meta": {
        "hostvars": {
            "10.68.68.5": {
                "ansible_connection": "ssh",
                "ansible_user": "azureuser"
            }
        },
        "profile": "inventory_legacy"
    },
    "all": {
        "children": [
            "ungrouped",
            "ot_nodes"
        ]
    },
    "ot_nodes": {
        "hosts": [
            "10.68.68.5"
        ]
    }
}
```
Update your root ansible.cfg file to set the default inventory path and disable strict host key checking for lab environments:

```bash
azureuser@ansiblectr01

cd io_ot_lab/

sudo nano ansible.cfg
```

```ini
[defaults]
callbacks_enabled = profile_tasks, timer
inventory = inventory/hosts.ini
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent
```

```bash

#  Verification: Run ansible-config view to confirm the active configuration.
ansible-config

# o view your active ansible.cfg configuration file cleanly, use the view action argument:
ansible-config view

```

### Enable passwordless, secure SSH authentication and log on ansiblectr01 in /opt/ansible

To enable passwordless, secure SSH authentication from your Ansible controller node (ansiblectr01, 10.68.68.4) to your target host (10.68.68.5), you need to generate an SSH key pair on the controller and copy the public key to the remote host.

```bash

azureuser@ansiblectr01

ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

ls -la ~/.ssh/id_rsa.pub

# Copy Public Key to Target Node
ssh-copy-id -i ~/.ssh/id_rsa.pub azureuser@10.68.68.5

# ssh login with key no pass
ssh azureuser@10.68.68.5

sudo mkdir -p /opt/ansible
sudo chown -R azureuser:azureuser /opt/ansible
```

Lets update the ansible.cfg and add a log path also

```ini
# Version: 1.1.0
# Description: Global Ansible configuration with password-prompted privilege escalation for lab automation.

[defaults]
inventory = ./inventory/hosts.ini
remote_user = azureuser
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
stdout_callback = default
log_path = /opt/ansible/automation.log

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

## Playbook linux ping_hosts.yml


```bash
azureuser@ansiblectr01

cd io_ot_lab/

sudo nano playbooks/ping_hosts.yml

```

ping_hosts.yml

```yml
---
# Version: 1.0.1
# Description: Ping validation playbook with privilege escalation explicitly disabled

- name: Verify Connectivity Across Purdue Lab Nodes
  hosts: ot_nodes
  gather_facts: false
  become: false
  tasks:
    - name: Ping all inventory hosts
      ansible.builtin.ping:
```


Run it

```bash
ansible-playbook -i inventory/hosts.ini playbooks/ping_hosts.yml
```
log

```console
PLAY [Verify Connectivity Across Purdue Lab Nodes] ******************************************

TASK [Ping all inventory hosts] *************************************************************
[...]
ok: [10.68.68.5]

PLAY RECAP **********************************************************************************
10.68.68.5                 : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


```

## Set up apt-cacher-ng and Apache on ansiblectr01


```bash
sudo apt update
sudo apt install -y apt-cacher-ng apache2


```
Allow HTTP tunnels through Apt-Cacher NG? Yes



### Allowed remote repositories

```bash

# Backup the existing configuration file
sudo cp /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.bak

# check what we have first
sudo grep -E "PassThroughPattern|Remap-(ubuntu|ppa|ansible|zabbix)" /etc/apt-cacher-ng/acng.conf

# The grep results show that PassThroughPattern is currently commented out or set to specific defaults, and none of your custom Remap rules are present yet.

# You can safely add your whitelisted repositories and update the PassThroughPattern to allow secure connections.

# Run the following command block to append your repository remapping rules to /etc/apt-cacher-ng/acng.conf:
sudo bash -c 'cat << '\''EOF'\'' >> /etc/apt-cacher-ng/acng.conf

# Ubuntu official mirrors and security updates
Remap-ubuntu: ubuntu.com archive.ubuntu.com security.ubuntu.com ; security.ubuntu.com/ubuntu

# Zabbix official repository
Remap-zabbix: repo.zabbix.com ; repo.zabbix.com/
EOF'

sudo tail -n 15 /etc/apt-cacher-ng/acng.conf

# Append the PassThroughPattern rule to allow secure APT traffic handling:
sudo bash -c 'echo "PassThroughPattern: .*" >> /etc/apt-cacher-ng/acng.conf'

sudo systemctl restart apt-cacher-ng

sudo systemctl status apt-cacher-ng
```


## Playbook linux configure_apt_proxy.yml


```bash
azureuser@ansiblectr01

cd io_ot_lab

sudo nano playbooks/cofigure_apt_proxy.yml


```
configure_apt_proxy.yml

```yml
---
# Version: 1.0.3
# Description: Configures APT HTTP and HTTPS proxy settings for internal caching across nodes.

- name: Configure Internal APT Caching Proxy
  hosts: ot_nodes
  become: true
  tasks:
    - name: Set APT Proxy configuration file
      ansible.builtin.copy:
        dest: /etc/apt/apt.conf.d/01proxy
        content: |
          Acquire::http::Proxy "http://10.68.68.4:3142/ubuntu/";
          Acquire::https::Proxy "http://10.68.68.4:3142/ubuntu/";
        owner: root
        group: root
        mode: '0644'

```

Run it

```bash
azureuser@ansiblectr01

cd io_ot_lab

ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml --check


```

Log

```console
PLAY [Configure Internal APT Caching Proxy] *************************************************

TASK [Gathering Facts] *********************************************************************
[...]

ok: [10.68.68.5]

TASK [Set APT Proxy configuration file] *****************************************************
changed: [10.68.68.5]

PLAY RECAP **********************************************************************************
10.68.68.5                 : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

The dry-run check mode completed successfully (changed=1, failed=0), confirming that Ansible can connect to your managed node and properly deploy the APT proxy configuration file.


Run it and apply it

```bash
azureuser@ansiblectr01

cd io_ot_lab

# ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml --limit ot_nodes
# or
ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml --limit zabbix01

```

log

```console
PLAY [Configure Internal APT Caching Proxy] *************************************************

TASK [Gathering Facts] **********************************************************************

[...]
TASK [Set APT Proxy configuration file] *****************************************************
changed: [zabbix01]

PLAY RECAP **********************************************************************************
zabbix01                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
### Veriy manual update on zabbix01


```bash
ssh azureuser@10.68.68.5

sudo apt update

sudo apt upgrade

```

![zabbix01 update](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/zabbix01_update.png)

Stop the apt cacher ng and verify no updates possible on zabbix01

```bash
azureuser@ansiblectr01

sudo systemctl stop apt-cacher-ng

ssh azureuser@10.68.68.5
```

No updates

The Connection refused error on port 3142 confirms that zabbix01 is actively trying to route its package updates through your controller's proxy, but the proxy service is currently stopped or unreachable.

Yes, exactly. The connection refusal error when the proxy service was stopped—followed by the successful package fetch once started—proves that zabbix01 relies entirely on your internal proxy (ansiblectr01 at 10.68.68.4:3142) for package updates.

![zabbix01 update fail](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/zabbix01_update_fail.png)


## Playbook linux update_apt.yml with callbacks_enabled = profile_tasks, timer

```bash
azureuser@ansiblectr01:~/io_ot_lab
sudo nano playbooks/update_apt.yml

```

update_apt.yml

```yml
---
# Version: 1.0.0
# Description: Updates package cache and safely upgrades system packages across managed nodes using the APT proxy.

- name: Update and Upgrade System Packages
  hosts: ot_nodes
  become: true
  tasks:
    - name: Update apt repository cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Perform a safe upgrade of installed packages
      ansible.builtin.apt:
        upgrade: safe
```
run it

```bash
ansiblectr01

cd io_ot_lab/

ansible-playbook -i inventory/hosts.ini playbooks/update_apt.yml --limit zabbix01 --check

# if the play is ok, remove --check with --diff and or --limit
ansible-playbook -i inventory/hosts.ini playbooks/update_apt.yml --limit zabbix01

```

log

```console
PLAY [Update and Upgrade System Packages] ***************************************************

TASK [Gathering Facts] **********************************************************************
Wednesday 11 November 2026  20:04:56 +0000 (0:00:00.014)       0:00:00.014 ****
ok: [zabbix01]

TASK [Update apt repository cache] **********************************************************
Wednesday 11 November 2026  20:04:58 +0000 (0:00:01.995)       0:00:02.010 ****
ok: [zabbix01]

TASK [Perform a safe upgrade of installed packages] *****************************************
Wednesday 11 November 2026  20:04:59 +0000 (0:00:00.897)       0:00:02.907 ****
ok: [zabbix01]

PLAY RECAP **********************************************************************************
zabbix01                   : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


TASKS RECAP *********************************************************************************
Wednesday 11 November 2026  20:05:00 +0000 (0:00:01.239)       0:00:04.147 ****
===============================================================================
Gathering Facts ---------------------------------------------------------------------- 2.00s
Perform a safe upgrade of installed packages ----------------------------------------- 1.24s
Update apt repository cache ---------------------------------------------------------- 0.90s

PLAYBOOK RECAP ******************************************************************************
Playbook run took 0 days, 0 hours, 0 minutes, 4 seconds
```

Now we have more output for time and date and more.


![playbook progress](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/playbook_progress.png)


## Current vms

![vms0](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vms0.png)


# Semaphore UI

## Install Semaphore UI on ansiblectr01

### We could do it with Ansible playbook also/ this is manual install to get to know it

To install Ansible Semaphore (a modern UI for Ansible) on your ansiblectr01 node, you can run Semaphore as a systemd service backed by a database (such as SQLite, which is lightweight and ideal for standalone controller nodes).

```bash
ansiblectr01

wget https://github.com/semaphoreui/semaphore/releases/download/v2.17.15/semaphore_2.17.15_linux_amd64.deb

ls -la semaphore_2.17.15_linux_amd64.deb
-rw-rw-r-- 1 azureuser azureuser 18833690 Feb 27  2026 semaphore_2.17.15_linux_amd64.deb

# Install the downloaded Debian package using dpkg:
sudo dpkg -i semaphore_2.17.15_linux_amd64.deb

# 
semaphore setup

```
1. Follow the interactive prompts to define your database settings, administrator account, and HTTP port.
Verification: Check that your configuration file (or database) has been created successfully in the directory specified during setup.

```txt

Sqlite

Configuration path: Press Enter to accept the default or specify /etc/semaphore/config.json.

Database dialect: Choose sqlite3.

Path to SQLite database: Specify /home/azureuser/io_ot_lab/semaphore.db

Path to Playbooks: Point this directly to your lab directory (/home/azureuser/io_ot_lab/playbooks).

Admin account details: Enter your desired username, email, and password for accessing the web UI.
```

2. Configure SQLite and Paths

Review your generated configuration file (for example, in your project folder or /etc/semaphore/config.json) to confirm that the SQLite database path and your Ansible playbook directories are correctly mapped:


```bash
ansiblectr01

ls
ansible.cfg  config.json  inventory  playbooks  semaphore.db

# check you config
cat config.json
```
Your config.json is missing the playbook_path and port keys required for Semaphore to locate your playbooks and serve the web interface. Update your config.json file to include them.

```bash
sudo nano config.json

```
Added

```json
"playbook_path": "/home/azureuser/io_ot_lab/playbooks",
        "port": "3000",
```
Rerun validation

```bash
semaphore setup --config /home/azureuser/io_ot_lab/config.json

# check all steps


```

Create service file

```bash
# Create the Systemd Service File
sudo nano /etc/systemd/system/semaphore.service
```

file

```ini
[Unit]
Description=Semaphore UI Ansible Automation Server
After=network.target

[Service]
User=azureuser
WorkingDirectory=/home/azureuser/io_ot_lab
ExecStart=/usr/bin/semaphore server --config /home/azureuser/io_ot_lab/config.json
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```
Reload it

```bash
# Reload systemd to recognize or update the service configuration, then start and enable Semaphore:
sudo systemctl daemon-reload
sudo systemctl enable --now semaphore.service

sudo systemctl status semaphore.service
● semaphore.service - Semaphore UI Ansible Automation Server
     Loaded: loaded (/etc/systemd/system/semaphore.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-11-11 20:27:17 UTC; 9s ago
```

### Accessing Semaphore UI


Add allow in semaphore 3000 tcp, NSG.


https://semaphoreui.com/docs/admin-guide/installation/package-manager


https://semaphoreui.com/


URL: [http://10.68.68.4:3000](http://10.68.68.4:3000) (or via your controller's accessible IP/port)


![sema](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/sema.png)

### SSL/TLS Certificates


```bash
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /home/azureuser/io_ot_lab/semaphore.key \
  -out /home/azureuser/io_ot_lab/semaphore.crt \
  -subj "/CN=10.68.68.4"

sudo chown azureuser:azureuser /home/azureuser/io_ot_lab/semaphore.key /home/azureuser/io_ot_lab/semaphore.crt
chmod 600 /home/azureuser/io_ot_lab/semaphore.key

sudo nano config.json
```

Update your /home/azureuser/io_ot_lab/config.json to include the certificate and key paths:

```json
"tls_cert": "/home/azureuser/io_ot_lab/semaphore.crt",
        "tls_key": "/home/azureuser/io_ot_lab/semaphore.key",
```

```bash
sudo systemctl restart semaphore.service
sudo systemctl status semaphore.service
```


Enable service

```bash
sudo nano /etc/systemd/system/semaphore.service
```

```ini

[Unit]
[Unit]
Description=Semaphore UI Ansible Automation Server
After=network.target

[Service]
User=azureuser
WorkingDirectory=/home/azureuser/io_ot_lab
ExecStart=/usr/bin/semaphore server --config /home/azureuser/io_ot_lab/config.json
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

```

```bash
sudo systemctl daemon-reload
sudo systemctl restart semaphore.service

 sudo systemctl status semaphore.service
● semaphore.service - Semaphore UI Ansible Automation Server
     Loaded: loaded (/etc/systemd/system/semaphore.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-11-11 20:42:22 UTC; 1min 23s ago
```

###  Apache in front of Semaphore for secure HTTPS access


```bash
 sudo systemctl status apache2.service
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-11-11 19:09:00 UTC; 1h 50min ago

# Enable Apache's proxy, proxy_http, ssl, and rewrite modules required for handling reverse proxying and SSL termination:
sudo a2enmod proxy proxy_http ssl rewrite headers

sudo nano /etc/apache2/sites-available/semaphore.conf
```

Use public ip not x.xxx.xx.x
```txt
<VirtualHost *:443>
    ServerName x.xx.xx.x

    SSLEngine on
    SSLCertificateFile /home/azureuser/io_ot_lab/semaphore.crt
    SSLCertificateKeyFile /home/azureuser/io_ot_lab/semaphore.key

    ProxyPreserveHost On
    ProxyRequests Off

    # Proxy traffic to Semaphore running on plain HTTP port 3000
    ProxyPass / http://127.0.0.1:3000/
    ProxyPassReverse / http://127.0.0.1:3000/

    # WebSocket support for live playbook logs
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /(.*)  ws://127.0.0.1:3000/$1 [P,L]
    RewriteCond %{HTTP:Upgrade} !=websocket [NC]
    RewriteRule /(.*)  http://127.0.0.1:3000/$1 [P,L]

    ErrorLog ${APACHE_LOG_DIR}/semaphore_error.log
    CustomLog ${APACHE_LOG_DIR}/semaphore_access.log combined
</VirtualHost>
```
Enable the Apache Site and Restart Service

```bash
sudo a2ensite semaphore.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl restart apache2

# Verification: The config test returns Syntax OK, and sudo systemctl status apache2 shows active (running).
sudo systemctl status apache2.service
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-11-11 21:01:03 UTC; 24s ago
```

Check your Inbound port rules to ensure there is a rule allowing TCP traffic on Port 443 from any source (or your client IP) to any destination.
Verification: If port 443 is missing, click Add inbound port rule, set destination port ranges to 443, protocol to TCP, action to Allow, and save.


Validity
Not Before
Wed, 11 Nov 2026 20:33:20 GMT
Not After
Sat, 08 Nov 2036 20:33:20 GMT 


![ssl](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/ssl.png)

now that Apache is handling SSL termination on port 443 and securely proxying traffic to Semaphore locally, you should clean up and close port 3000 in your Azure Network Security Group (NSG) so external traffic is forced through the secure HTTPS proxy.

![nsg remove](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/nsg_remove.png)

https://www.sslshopper.com/ssl-checker.html

Yes we use a self signed cert.

![cert2](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/cert2.png)




## Setup Ansible ansiblectr01 with Semaphore

* Playbooks live locally: You write, edit, and store your .yml playbook files directly in your local directory on the controller node (/home/azureuser/io_ot_lab/playbooks/).
* Semaphore links to them: Semaphore reads those local files (or your connected Git repository) and provides the buttons, access keys, inventory mappings, and web triggers to execute them.

Next Steps in the Web Interface

Log into Semaphore, click New Project, enter IO-OT Lab as the project name, and click Create.
Verification: You are redirected to the new project dashboard view.

🔵 Add Repository: Point Semaphore to your local playbook directory or a Git repository if applicable.

🔵 Add Inventory: Define your inventory path (inventory/hosts.ini).

🔵 Add Environment / Access Keys: Configure your SSH private key so Semaphore can authenticate against your managed nodes (zabbix01, mysql01, zabbix02).

🔵 Create Templates: Link your playbooks (configure_apt_proxy.yml, update_apt.yml) to templates for easy execution directly from the dashboard

![setup sema2](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/setup_sema2.png)


## Playbooks linux Semaphore run

What to Do Next

To start running your automation tasks, you can proceed with creating your execution templates:

* Create Templates: Go to Templates in your Semaphore dashboard and link your playbooks (ping_hosts.yml, update_apt.yml, configure_apt_proxy.yml) to your Lab Inventory and Lab SSH Key.

* Run and Test: Trigger a run directly from the dashboard to verify that Semaphore successfully executes your playbooks against your lab nodes over SSH.


### linux ping_hosts.yml

![play ping](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/play_ping.png)

Run the playbook

![run sema ping](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/run_sema_ping.png)

Verify in Semaphore

![run sema ping verify](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/run_sema_ping_verify.png)

### linux update_apt.yml

![run sema apt](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/run_sema_apt.png)

Success, we updated zabbix01


![run sema apt_Ok](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/run_sema_apt_ok.png)


Success


Status for playbooks

![status sema](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/status_sema.png)


# 2. Topology at this stage

```mermaid
graph TD
    subgraph Zone1 ["External Access public ip"]
        Internet["INTERNET<br/>(EXTERNAL REPOSITORIES)"]
    end

    subgraph Zone2 ["Zone 2.5: Controller Node (ansiblectr01 / Azure VM)"]
        subgraph Subnet1 ["Subnet 1 (iDMZ / Management) - zone 2.5<br/>Address range: 10.68.68.0/24"]
            direction TB
            ansiblectr01["ansiblectr01<br/>10.68.68.4<br/>Ansible Control Node & Semaphore<br/>Ubuntu 22.04, Apache, APT Cacher NG Proxy"]
            zabbix01["zabbix01<br/>IP: 10.68.68.5"]
            mysql01["mysql01<br/>IP: tbd<br/>---"]
        end
    end

    subgraph Zone2OT ["Subnet 2 (OT / Target) - zone 2.0"]
        direction TB
        subgraph Subnet2 ["Address range: 10.68.20.0/24"]
            zabbix02["zabbix02 Active proxy<br/>IP: tbd"]
            winVMs["20-30 WINDOWS VMs<br/>10.68.20.100+"]
        end
    end

    subgraph AdminNet ["Admin / IT Network Zone 3"]
        AdminPC["Admin PC/ Jump Server (now we use ssh to Azure ansiblectr01 via public ip)"]
    end

    Internet -->|HTTP HTTPS Port 80, 443| ansiblectr01
    AdminPC -->|TCP 80/443 Zabbix Web UI| zabbix01
    AdminPC -->|TCP 443 Semaphore Web UI| ansiblectr01
    AdminPC -->|TCP 22 SSH| ansiblectr01
    
    ansiblectr01 -->|APT Cache TCP 3142| zabbix01
    ansiblectr01 -->|TCP 22 Ansible Playbook| zabbix01
    
    ansiblectr01 -.->|TCP 22 Ansible Playbook| zabbix02
    zabbix01 -.->|TCP 10051 Active Push| zabbix02

```

This is the final set up (ip may change but the concept is the same)

![topology](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/topology.png)

# Set up the rest of the stack

## Create mysql01 and zabbix02

* Create mysql01 and add a extra datadisk with 32 GB

![disk](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/disk.png)

Vm mysql01 created 10.68.68.6

![vms1](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vms1.png)

* Create zabbix02

![vms all](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vms_all.png)

Azure vms

![azure_vms](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/azure_vms.png)

## No outbound to internet

Vms

![vms_nsg](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vms_nsg.png)

Ansible

![vms_nsg_ansible](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vms_nsg_ansible.png)

## Structure inventory/hosts.ini and align all configurations

```ini
[idmz_nodes]
zabbix01 ansible_host=10.68.68.5 ansible_user=azureuser  ansible_python_interpreter=/usr/bin/python3.14
mysql01 ansible_host=10.68.68.6 ansible_user=azureuser  ansible_python_interpreter=/usr/bin/python3.14

[ot_nodes]
zabbix02 ansible_host=10.68.20.4 ansible_user=azureuser

[idmz_nodes:vars]
ansible_connection=ssh

[ot_nodes:vars]
ansible_connection=ssh

[all:vars]
ansible_python_interpreter=auto_silent


```

### Add ssh keys for new hosts

```bash

# Copy SSH Public Key to mysql01
ssh-copy-id -i ~/.ssh/id_rsa.pub azureuser@10.68.68.6

ssh azureuser@10.68.68.6

# Copy SSH Public Key to zabbix02
ssh-copy-id -i ~/.ssh/id_rsa.pub azureuser@10.68.20.4

ssh azureuser@10.68.20.4
```

### Playbook linux yml update hosts and verify current templates

Update all templates with more hosts since we have added.

hosts: ot_nodes

Update

hosts: ot_nodes:idmz_nodes
```yml
---
# Version: 1.0.1
# Description: Ping validation playbook with privilege escalation explicitly disabled

- name: Verify Connectivity Across Purdue Lab Nodes
  hosts: ot_nodes:idmz_nodes
```

Run it

```bash
azureuser@ansiblectr01:~/io_ot_lab

ansible-playbook -i inventory/hosts.ini playbooks/ping_hosts.yml
```

log

```console
PLAY [Verify Connectivity Across Purdue Lab Nodes] *********************************************************************

TASK [Ping all inventory hosts] ****************************************************************************************
Thursday 12 November 2026  08:51:31 +0000 (0:00:00.011)       0:00:00.011 *****
ok: [mysql01]
ok: [zabbix01]
ok: [zabbix02]

PLAY RECAP *************************************************************************************************************
mysql01                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix01                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix02                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


TASKS RECAP ************************************************************************************************************
Thursday 12 November 2026  08:51:32 +0000 (0:00:01.167)       0:00:01.178 *****
===============================================================================
Ping all inventory hosts ---------------------------------------------------------------------------------------- 1.17s

PLAYBOOK RECAP *********************************************************************************************************
Playbook run took 0 days, 0 hours, 0 minutes, 1 seconds
```

## Run linux ping_hosts.yml Semaphore

It automatically picks up all our new hosts.

![sema ping](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/sema_ping.png)

### Playbook Linux verify_isolation.yml

verify isolation no internet for linux

![verify_iso](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/verify_iso.png)


### Playbook Linux configure_apt_proxy.yml

Now run cofigure proxy to apply to new nodes

![conf_proxy_new](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/conf_proxy_new.png)


### Playbook Linux update_apt.yml patch all hosts with one click

Now update all servers with the apt playbook.

![one_click_update](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/one_click_update.png)


All Playbooks are success and ready

![first_4_play](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/first_4_play.png)



## Playbook Configure a Dedicated Template per Host/Group (Recommended) in Semaphore

```bash
# ansible we can run
azureuser@ansiblectr01:~/io_ot_lab

# all vms
ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml

# just one
ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml --limit zabbix01
```
In Semaphore, templates are designed to be reusable workflows. Rather than manually typing --limit every time, the cleanest approach is to create distinct templates mapped to specific inventory groups or hosts:

1. Go to Templates and click New Template.

2. Name it something descriptive, such as Update APT - zabbix01 only.

3. Select your playbook (playbooks/update_apt.yml).

4. Select your Inventory (hosts.ini).

5. In the Limit field provided by Semaphore's template settings, enter your specific host or group name (e.g., zabbix01 or ot_nodes).

6. Click Save.

Verification: Launching this template automatically applies the limit without requiring manual command-line flags.

## Semaphore statistic


![stats](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/stats.png)

![stats2](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/stats2.png)


Semaphore does not include a real-time monitoring dashboard or continuous health-status tracking for hosts. Because Semaphore is an automation and orchestration platform rather than a monitoring system, it evaluates host status based on playbook execution results.

Host statuses and health are tracked and viewed in Semaphore through specific mechanisms:

* Task Execution Recaps: Every time you run a playbook template (such as ping_hosts.yml or update_apt.yml), Semaphore captures the standard Ansible output. In the task log, you can view the PLAY RECAP for every run, which explicitly reports whether each host returned ok, changed, unreachable, or failed.

* Inventory Inspection: You can view your configured static inventory (hosts.ini) and check which hosts are mapped under your projects, but this displays configuration definitions rather than live operational metrics.

For continuous real-time host status, performance metrics, and alerting in your lab architecture, that role is handled by your Zabbix infrastructure (zabbix01 and zabbix02), while Semaphore handles running on-demand or scheduled automation playbooks.

# Playbooks with Ansible (Now we can really start)

Now all the configuration and setup is done

* ssh works
* Ping works
* Linux updates with apt cacher ng works
* All nodes are isolated with no internet access

# 3. Topology at this stage

```mermaid
graph TD
    subgraph Zone1 ["External Access public ip"]
        Internet["INTERNET<br/>(EXTERNAL REPOSITORIES)"]
    end

    subgraph Zone2 ["Zone 2.5: Controller Node (ansiblectr01 / Azure VM)"]
        subgraph Subnet1 ["Subnet 1 (iDMZ / Management) - zone 2.5<br/>Address range: 10.68.68.0/24"]
            direction TB
            ansiblectr01["ansiblectr01<br/>10.68.68.4<br/>Ansible Control Node & Semaphore<br/>Ubuntu 22.04, Apache, APT Cacher NG Proxy"]
            zabbix01["zabbix01<br/>IP: 10.68.68.5"]
            mysql01["mysql01<br/>IP: 10.68.68.6"]
        end
    end

    subgraph Zone2OT ["Subnet 2 (OT / Target) - zone 2.0"]
        direction TB
        subgraph Subnet2 ["Address range: 10.68.20.0/24"]
            zabbix02["zabbix02 Active proxy<br/>IP: 10.68.20.4"]
            winVMs["20-30 WINDOWS VMs<br/>10.68.20.100+"]
        end
    end

    subgraph AdminNet ["Admin / IT Network Zone 3"]
        AdminPC["Admin PC/ Jump Server (SSH to Azure ansiblectr01 via public IP)"]
    end

    Internet -->|HTTP HTTPS Port 80, 443| ansiblectr01
    AdminPC -->|TCP 80/443 Zabbix Web UI| zabbix01
    AdminPC -->|TCP 443 Semaphore Web UI| ansiblectr01
    AdminPC -->|TCP 22 SSH| ansiblectr01
    
    ansiblectr01 -->|APT Cache TCP 3142| zabbix01
    ansiblectr01 -->|APT Cache TCP 3142| mysql01
    ansiblectr01 -->|TCP 22 Ansible Playbook| zabbix01
    ansiblectr01 -->|TCP 22 Ansible Playbook| mysql01
    
    ansiblectr01 -.->|APT Cache TCP 3142| zabbix02
    ansiblectr01 -.->|TCP 22 Ansible Playbook| zabbix02
    zabbix01 -.->|TCP 10051 Active Push| zabbix02
```


## Update inventory/host.ini


```ini
# Version: 2.0.0
# Description: Multi-zone Ansible static inventory defining topological zones, functional roles, and connection parameters.

[control_node]
ansiblectr01 ansible_host=10.68.68.4 ansible_user=azureuser ansible_python_interpreter=/usr/bin/python3.14 ansible_connection=local

[idmz_nodes]
zabbix01 ansible_host=10.68.68.5 ansible_user=azureuser ansible_python_interpreter=/usr/bin/python3.14
mysql01 ansible_host=10.68.68.6 ansible_user=azureuser ansible_python_interpreter=/usr/bin/python3.14

[ot_nodes]
zabbix02 ansible_host=10.68.20.4 ansible_user=azureuser

[db_servers]
mysql01 ansible_host=10.68.68.6 ansible_user=azureuser ansible_python_interpreter=/usr/bin/python3.14

[zabbix_servers]
zabbix01 ansible_host=10.68.68.5 ansible_user=azureuser ansible_python_interpreter=/usr/bin/python3.14

[zabbix_proxies]
zabbix02 ansible_host=10.68.20.4 ansible_user=azureuser ansible_python_interpreter=/usr/bin/python3.14

[idmz_nodes:vars]
ansible_connection=ssh

[ot_nodes:vars]
ansible_connection=ssh

[all:vars]
ansible_python_interpreter=auto_silent

[io_ot_lab:children]
idmz_nodes
ot_nodes
```

🔵 [control_node]: Groups the local Ansible controller node so that playbooks can execute locally via loopback connections without unnecessary network overhead.

🔵 [idmz_nodes]: Groups all internal Demilitarized Zone management servers together to manage shared security policies and local software repositories cleanly.

🔵 [ot_nodes]: Groups all Operational Technology network targets together to isolate industrial systems from management traffic boundaries.

🔵 [db_servers]: Groups database instances like MySQL so database-specific deployment and tuning playbooks target only relational storage hosts.

🔵 [zabbix_servers]: Groups core Zabbix monitoring servers together to target application-specific updates and configuration management tasks.

🔵 [zabbix_proxies]: Groups Zabbix proxy nodes to streamline data collection routing across segregated network boundaries.

🔵 [idmz_nodes:vars]: Assigns shared SSH connection parameters specifically to management zone hosts to guarantee correct remote transport behavior.

🔵 [ot_nodes:vars]: Applies specific OT network connection settings to target nodes to enforce appropriate transport rules across firewalls.

🔵 [all:vars]: Defines global variables inherited across every inventory host to ensure uniform Python interpreter settings without redundant configuration.

🔵[io_ot_lab:children]: Combines multiple sub-groups into a unified parent group to let you run playbooks across the entire laboratory infrastructure with a single target reference.

## Playbook get_linux_version.yml

```bash

ansible-playbook -i inventory/hosts.ini playbooks/get_linux_version.yml
```


## Playbook linux mount_datadrive_check.yml --check --limit


Now we can use the mapping in hosts.ini to only target our host in the playbook.

🔵 [db_servers]: Groups database instances like MySQL so database-specific deployment and tuning playbooks target only relational storage hosts.

🔵 you can target the group db_servers directly (since mysql01 is already a member of that group

```bash
azureuser@ansiblectr01:~/io_ot_lab

cd io_ot_lab/

# if the play is ok, remove --check with --diff and or --limit

ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive_check.yml

```

log

```console
PLAY [Check mount secondary data drive] ********************************************************************************

TASK [Gathering Facts] *************************************************************************************************
Thursday 12 November 2026  20:38:41 +0000 (0:00:00.016)       0:00:00.016 *****
ok: [mysql01]

TASK [Gather block device information] *********************************************************************************
Thursday 12 November 2026  20:38:43 +0000 (0:00:01.997)       0:00:02.013 *****
ok: [mysql01]

TASK [Display available block devices] *********************************************************************************
Thursday 12 November 2026  20:38:43 +0000 (0:00:00.525)       0:00:02.539 *****
ok: [mysql01] => {
    "msg": [
        "NAME     SIZE FSTYPE MOUNTPOINTS",
        "sda       32G        ",
        "sdb       30G        ",
        "├─sdb1  28.9G ext4   /",
        "├─sdb13 1023M ext4   /boot",
        "├─sdb14    4M        ",
        "└─sdb15  106M vfat   /boot/efi",
        "sdc        8G        ",
        "└─sdc1     8G ext4   /mnt"
    ]
}

PLAY RECAP *************************************************************************************************************
mysql01                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


TASKS RECAP ************************************************************************************************************
Thursday 12 November 2026  20:38:43 +0000 (0:00:00.022)       0:00:02.562 *****
===============================================================================
Gathering Facts ------------------------------------------------------------------------------------------------- 2.00s
Gather block device information --------------------------------------------------------------------------------- 0.53s
Display available block devices --------------------------------------------------------------------------------- 0.02s

PLAYBOOK RECAP *********************************************************************************************************
Playbook run took 0 days, 0 hours, 0 minutes, 2 seconds

```



## Playbook linux mount_datadrive.yml


```bash
azureuser@ansiblectr01:~/io_ot_lab

cd io_ot_lab/

# if the play is ok, remove --check with --diff and or --limit

ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive.yml --check

```

The error occurred because you ran the playbook with the --check (dry run) flag. When running in check mode, Ansible simulates the partitioning task (parted), but it does not actually create /dev/sda1 on the system.

Run without check mode (Live Execution): Since partition creation and formatting are idempotent or intended to apply changes, run the playbook normally without --check.


```bash
ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive.yml
```

log
```console
PLAY [Inspect, configure, and mount secondary data drive] **************************************************************

TASK [Gathering Facts] *************************************************************************************************
Thursday 12 November 2026  20:50:52 +0000 (0:00:00.012)       0:00:00.012 *****
ok: [mysql01]

TASK [Gather block device information with size] ***********************************************************************
Thursday 12 November 2026  20:50:54 +0000 (0:00:01.841)       0:00:01.853 *****
ok: [mysql01]

TASK [Display available block devices] *********************************************************************************
Thursday 12 November 2026  20:50:55 +0000 (0:00:00.484)       0:00:02.338 *****
ok: [mysql01] => {
    "msg": [
        "NAME     SIZE FSTYPE MOUNTPOINTS",
        "sda       32G        ",
        "sdb       30G        ",
        "├─sdb1  28.9G ext4   /",
        "├─sdb13 1023M ext4   /boot",
        "├─sdb14    4M        ",
        "└─sdb15  106M vfat   /boot/efi",
        "sdc        8G        ",
        "└─sdc1     8G ext4   /mnt"
    ]
}

TASK [Create primary partition on sda] *********************************************************************************
Thursday 12 November 2026  20:50:55 +0000 (0:00:00.025)       0:00:02.363 *****
changed: [mysql01]

TASK [Create ext4 filesystem on sda1] **********************************************************************************
Thursday 12 November 2026  20:50:55 +0000 (0:00:00.819)       0:00:03.183 *****
changed: [mysql01]

TASK [Ensure mount point directory exists] *****************************************************************************
Thursday 12 November 2026  20:50:57 +0000 (0:00:01.721)       0:00:04.904 *****
changed: [mysql01]

TASK [Mount secondary drive persistently] ******************************************************************************
Thursday 12 November 2026  20:50:58 +0000 (0:00:00.490)       0:00:05.395 *****
changed: [mysql01]

PLAY RECAP *************************************************************************************************************
mysql01                    : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


TASKS RECAP ************************************************************************************************************
Thursday 12 November 2026  20:50:59 +0000 (0:00:01.323)       0:00:06.718 *****
===============================================================================
Gathering Facts ------------------------------------------------------------------------------------------------- 1.84s
Create ext4 filesystem on sda1 ---------------------------------------------------------------------------------- 1.72s
Mount secondary drive persistently ------------------------------------------------------------------------------ 1.32s
Create primary partition on sda --------------------------------------------------------------------------------- 0.82s
Ensure mount point directory exists ----------------------------------------------------------------------------- 0.49s
Gather block device information with size ----------------------------------------------------------------------- 0.48s
Display available block devices --------------------------------------------------------------------------------- 0.03s

PLAYBOOK RECAP *********************************************************************************************************
```

Lets inspect the disk

```bash
# we use our check playbook
ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive_check.yml
```

log

```console
TASK [Display available block devices] *********************************************************************************
Thursday 12 November 2026  20:52:43 +0000 (0:00:00.501)       0:00:02.364 *****
ok: [mysql01] => {
    "msg": [
        "NAME     SIZE FSTYPE MOUNTPOINTS",
        "sda       32G        ",
        "└─sda1    32G        /var/lib/mysql",
        "sdb       30G        ",
        "├─sdb1  28.9G ext4   /",
        "├─sdb13 1023M ext4   /boot",
        "├─sdb14    4M        ",
        "└─sdb15  106M vfat   /boot/efi",
        "sdc        8G        ",
        "└─sdc1     8G ext4   /mnt"
    ]
}

PLAY RECAP *************************************************************************************************************
mysql01                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


The playbook ran cleanly with zero failures (ok=7 changed=4 failed=0), successfully partitioning /dev/sda, creating the ext4 filesystem, provisioning the /var/lib/mysql mount point, and configuring persistent mounting.

## Playbook linux tbd.yml


```bash
azureuser@ansiblectr01:~/io_ot_lab

cd io_ot_lab/

# if the play is ok, remove --check with --diff and or --limit

# Version: 1.2.0
# Description: Verifies network isolation by checking if managed nodes can reach www.google.com.
ansible-playbook -i inventory/hosts.ini playbooks/

```

# Create a Windows host

## Playbook windows tbd




