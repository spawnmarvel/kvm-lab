# Ansible stack in Azure

Do the same as with KVM for repetions and demo online


## Table of content
- [Ansible stack in Azure](#ansible-stack-in-azure)
  - [Table of content](#table-of-content)
  - [Virtual machines in Rg-swc-ansiblestack-01](#virtual-machines-in-rg-swc-ansiblestack-01)
  - [Virtual machines in Rg-swc-vms-01](#virtual-machines-in-rg-swc-vms-01)
  - [Vnet and subnet](#vnet-and-subnet)
  - [Create ansiblectr01, 10.68.68.10](#create-ansiblectr01-10686810)
  - [Install Ansible ansiblectr01](#install-ansible-ansiblectr01)
  - [Install Semaphore UI internet exposed](#install-semaphore-ui-internet-exposed)
  - [Setup Ansible ansiblectr01 with Semaphore](#setup-ansible-ansiblectr01-with-semaphore)
  - [Setup a vm zabbix01](#setup-a-vm-zabbix01)
  - [Playbooks](#playbooks)

## Virtual machines in Rg-swc-ansiblestack-01

* ansiblectr01, 10.68.68.10, with public ip and allow internet

## Virtual machines in Rg-swc-vms-01

* zabbix01, 10.68.68.50, with public ip also, but no outbund internet, deny with NSG
* mysql01, 10.68.68.52, no outbund internet by default
* zabbix02, 10.68.20.15, no outbund internet by default

## Vnet and subnet

Subnet 1 (iDMZ / Management):

Address range: 10.68.68.0/24

Covers: 10.68.68.10 (ansiblectr01), 10.68.68.50 (zabbix01), and 10.68.68.52 (mysql01).

Subnet 2 (OT / Target):

Address range: 10.68.20.0/24

Covers: 10.68.20.15 (zabbix02)


![vnet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack/images/vnet.png)

## Create ansiblectr01, 10.68.68.10

## Install Ansible ansiblectr01

## Install Semaphore UI internet exposed

https://semaphoreui.com/

## Setup Ansible ansiblectr01 with Semaphore


```bash

```

## Setup a vm zabbix01

```bash

```

## Playbooks



