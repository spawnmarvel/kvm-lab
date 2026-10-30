# Getting started with Ansible

## Table of content

- [Getting started with Ansible](#getting-started-with-ansible)
  - [Table of content](#table-of-content)
  - [Getting started with Ansible](#getting-started-with-ansible-1)

# Getting started with Ansible


Control node (Ansible node):

* kvm-host-HP-ProDesk-600-G3-SFF

We have the two following host from the previous build.

* Zabbix01, 10.68.68.50
* Zabbix02, 10.68.68.51

```bash
ssh proxyman@10.68.68.51
ssh master@10.68.68.50
```  

## 1. Start automating with Ansible ssh keys

```bash
mkdir ansible_quickstart
cd ansible_quickstart

sudo nano inventory.ini
```

Add the hosts

```ini
[myhost]
10.68.68.50
10.68.68.51

```

* https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_ansible.html


## 2. Building an inventory with users production-grade

To complete the following steps, you will need the IP address or fully qualified domain name (FQDN) of at least one host system. 


To configure Ansible so it uses those specific usernames for each host automatically, you can update your inventory.ini file to define ansible_user for each node:


```ini
[myhost]
10.68.68.50 ansible_user=master
10.68.68.51 ansible_user=proxyman
``` 


Permanent Fix: Copy SSH Key (Recommended)

```bash
ssh-copy-id master@10.68.68.50
ssh-copy-id proxyman@10.68.68.51
```

Defining target usernames in the inventory and using SSH key authentication is the standard, production-grade practice for Ansible.


Verify inventory

```bash
ansible-inventory -i inventory.ini --list

# ping the host
ansible myhost -m ping -i inventory.ini 


```

Ping: pong

```json
10.68.68.50 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.14"
    },
    "changed": false,
    "ping": "pong"
}

10.68.68.51 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.14"
    },
    "changed": false,
    "ping": "pong"
}

```
Inventories in INI or YAML format.

Creating an inventory in YAML format becomes a sensible option as the number of managed nodes increases. 



* https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_inventory.html

## 3. Creating a playbook


1. Playbook
A list of plays that define the order in which Ansible performs operations, from top to bottom, to achieve an overall goal.

2. Play
An ordered list of tasks that maps to managed nodes in an inventory.

3. Task
A reference to a single module that defines the operations that Ansible performs.

4. Module
A unit of code or binary that Ansible runs on managed nodes. Ansible modules are grouped in collections with a Fully Qualified Collection Name (FQCN) for each module.


```bash
pwd
/home/espenk/ansible_quickstart



``` 
https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_playbook.html

## continue

Just do for fun and recap.

https://docs.ansible.com/projects/ansible/latest/getting_started/index.html