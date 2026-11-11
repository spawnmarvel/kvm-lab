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
    - [We could do it with Ansible playbook also/ this is manual install to get to know it](#we-could-do-it-with-ansible-playbook-also-this-is-manual-install-to-get-to-know-it)
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

![ansible](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/ansiblectr01.png)

## Install Ansible on ansiblectr01


ansiblectr01 | Network settings Outbund port rule added

Allow_internet

![nsg inet](https://github.com/spawnmarvel/kvm-lab/blob/main/run_research_2_azure_zabbix_stack_extra_with_windows_vms/images/nsg_inet.png)

```bash

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

## Install Semaphore UI on ansiblectr01

### We could do it with Ansible playbook also/ this is manual install to get to know it

To install Ansible Semaphore (a modern UI for Ansible) on your ansiblectr01 node, you can run Semaphore as a systemd service backed by a database (such as SQLite, which is lightweight and ideal for standalone controller nodes).

```bash

wget https://github.com/semaphoreui/semaphore/releases/download/v2.17.15/semaphore_2.17.15_linux_amd64.deb

ls -la semaphore_2.17.15_linux_amd64.deb
-rw-rw-r-- 1 azureuser azureuser 18833690 Feb 27  2026 semaphore_2.17.15_linux_amd64.deb

# Install the downloaded Debian package using dpkg:
sudo dpkg -i semaphore_2.17.15_linux_amd64.deb

# 
semaphore setup

```
Follow the interactive prompts to define your database settings, administrator account, and HTTP port.
Verification: Check that your configuration file (or database) has been created successfully in the directory specified during setup.

Add allow in semaphore 3000 tcp, NSG.


https://semaphoreui.com/docs/admin-guide/installation/package-manager


https://semaphoreui.com/

## Setup Ansible ansiblectr01 with Semaphore


```bash

```

## Create zabbix01 Subnet 1 (iDMZ / Management)

```bash

```

## Playbooks



