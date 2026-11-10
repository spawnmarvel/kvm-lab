# Ansible stack in Azure

Do the same as with KVM for repeat it


## Table of content
- [Ansible stack in Azure](#ansible-stack-in-azure)
  - [Table of content](#table-of-content)
  - [Virtual machines in Rg-swc-ansiblestack-01](#virtual-machines-in-rg-swc-ansiblestack-01)
  - [Create ansiblectr01, 10.68.68.10 whitelist FW NSG](#create-ansiblectr01-10686810-whitelist-fw-nsg)
  - [Install Ansible ansiblectr01](#install-ansible-ansiblectr01)
  - [Install Semaphore UI](#install-semaphore-ui)
  - [Setup Ansible ansiblectr01](#setup-ansible-ansiblectr01)
  - [Playbooks](#playbooks)

## Virtual machines in Rg-swc-ansiblestack-01

* ansiblectr01, 10.68.68.10
* zabbix01, 10.68.68.50
* mysql01, 10.68.68.52
* zabbix02, 10.68.20.15

Subnet 1 (iDMZ / Management):

Address range: 10.68.68.0/24

Covers: 10.68.68.10 (ansiblectr01), 10.68.68.50 (zabbix01), and 10.68.68.52 (mysql01).

Subnet 2 (OT / Target):

Address range: 10.68.20.0/24

Covers: 10.68.20.15 (zabbix02)


![vnet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack/images/vnet.png)

## Create ansiblectr01, 10.68.68.10 whitelist FW NSG

## Install Ansible ansiblectr01

## Install Semaphore UI

https://semaphoreui.com/

## Setup Ansible ansiblectr01

## Playbooks



