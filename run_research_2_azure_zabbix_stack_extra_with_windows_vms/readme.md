# Ansible stack in Azure

Do the same as with KVM for repetions and demo online


## Table of content
- [Ansible stack in Azure](#ansible-stack-in-azure)
  - [Table of content](#table-of-content)
  - [Vnet and subnet](#vnet-and-subnet)
  - [Virtual machines in Rg-swc-ansiblestack-01](#virtual-machines-in-rg-swc-ansiblestack-01)
  - [Virtual machines in Rg-swc-vms-01](#virtual-machines-in-rg-swc-vms-01)
  - [Create ansiblectr01 Subnet 1 (iDMZ / Management)](#create-ansiblectr01-subnet-1-idmz--management)
  - [Install Ansible on ansiblectr01](#install-ansible-on-ansiblectr01)
  - [Install Semaphore UI on ansiblectr01](#install-semaphore-ui-on-ansiblectr01)
  - [Setup Ansible ansiblectr01 with Semaphore](#setup-ansible-ansiblectr01-with-semaphore)
  - [Create zabbix01 Subnet 1 (iDMZ / Management)](#create-zabbix01-subnet-1-idmz--management)
  - [Playbooks](#playbooks)


## Vnet and subnet

Subnet 1 (iDMZ / Management):

Address range: 10.68.68.0/24

Covers: 10.68.68.10 (ansiblectr01), 10.68.68.50 (zabbix01), and 10.68.68.52 (mysql01).

Subnet 2 (OT / Target):

Address range: 10.68.20.0/24

Covers: 10.68.20.15 (zabbix02)


![vnet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/vnet.png)

## Virtual machines in Rg-swc-ansiblestack-01

* ansiblectr01, 10.68.68.10, with public ip and allow internet
* azureuser/ ouch no-> imsdal, you know


## Virtual machines in Rg-swc-vms-01

* zabbix01, 10.68.68.50, with public ip also, but no outbund internet, deny with NSG
* mysql01, 10.68.68.52, no outbund internet by default
* zabbix02, 10.68.20.15, no outbund internet by default

## Create ansiblectr01 Subnet 1 (iDMZ / Management)

## Install Ansible on ansiblectr01


ansiblectr01 | Network settings Outbund port rule added

Allow_internet

![nsg inet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/nsg_inet.png)

```bash

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

https://docs.ansible.com/projects/ansible/latest/installation_guide/installation_distros.html

## Install Semaphore UI on ansiblectr01

https://semaphoreui.com/

## Setup Ansible ansiblectr01 with Semaphore


```bash

```

## Create zabbix01 Subnet 1 (iDMZ / Management)

```bash

```

## Playbooks



