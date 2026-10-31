# Getting started with Ansible

## Table of content

- [Getting started with Ansible](#getting-started-with-ansible)
  - [Table of content](#table-of-content)
- [Getting started with Ansible](#getting-started-with-ansible-1)
  - [The KVM host 192.168.10.70](#the-kvm-host-1921681070)
  - [1. Start automating with Ansible ssh keys](#1-start-automating-with-ansible-ssh-keys)
  - [2. Building an inventory with users production-grade](#2-building-an-inventory-with-users-production-grade)
  - [3. Creating a playbook](#3-creating-a-playbook)
  - [4. Quick sandbox playbook or a cheatsheet of essential ad-hoc commands tuned for your hybrid Linux/Windows environment](#4-quick-sandbox-playbook-or-a-cheatsheet-of-essential-ad-hoc-commands-tuned-for-your-hybrid-linuxwindows-environment)
    - [4.1 Why This Is the Correct Security Model](#41-why-this-is-the-correct-security-model)
  - [5. Ansible playbooks Start building playbooks for real world scenarios TODO](#5-ansible-playbooks-start-building-playbooks-for-real-world-scenarios-todo)
  - [KVM snapshots and environment](#kvm-snapshots-and-environment)
  - [Working with playbooks Gemini Research Purdue Model 3 ways automation = in progress](#working-with-playbooks-gemini-research-purdue-model-3-ways-automation--in-progress)
    - [1. You use ansible.builtin.file almost 100% of the time in production playbook](#1-you-use-ansiblebuiltinfile-almost-100-of-the-time-in-production-playbook)
    - [2. To ensure a package is installed and its service is active and enabled on boot](#2-to-ensure-a-package-is-installed-and-its-service-is-active-and-enabled-on-boot)
  - [Ansible tips and tricks documentation TODO READ](#ansible-tips-and-tricks-documentation-todo-read)
  - [What more do we need to learn Gemini? TODO](#what-more-do-we-need-to-learn-gemini-todo)

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

## The KVM host 192.168.10.70

```bash
ssh espenk@192.168.10.70
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

sudo nano playbook.yaml

``` 

Create a file named playbook.yaml in your ansible_quickstart directory, that you created earlier, with the following content:


```yml
- name: My first play
  hosts: myhosts
  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:

   - name: Print message
     ansible.builtin.debug:
       msg: Hello world

```

Run it

```bash
ansible-playbook -i inventory.ini playbook.yaml 

```

Result

```txt
PLAY [First playbook] **************************************************************************

TASK [Gathering Facts] *************************************************************************
TASK [Ping my hosts] ***************************************************************************
ok: [10.68.68.51]
ok: [10.68.68.50]

TASK [Print message] ***************************************************************************
ok: [10.68.68.50] => {
    "msg": "Hello world"
}
ok: [10.68.68.51] => {
    "msg": "Hello world"
}

PLAY RECAP *************************************************************************************


```


## 4. Quick sandbox playbook or a cheatsheet of essential ad-hoc commands tuned for your hybrid Linux/Windows environment

That is a flawless execution! Getting SUCCESS => {"ping": "pong"} across those targets proves you have successfully crossed the three most common hurdles in Ansible:

* Host Connectivity: Network routing between the nodes is wide open.
* Authentication: Your non-root custom users (master, proxyman) are correctly mapped via inventory.ini, and SSH keys (ssh-copy-id) are actively bypassing password prompts securely.
* Internal Dependencies: The hosts successfully found and executed Python (/usr/bin/python3.14 in Ubuntu 26.04/Noble or local sandbox build), which Ansible requires on the target.


Ensure your custom users can scale up to administrative privileges (required for installing packages and configuring storage).


* SSH Key Authentication (ssh-copy-id): Grants permission to open an SSH session to the host as master or proxyman without entering an SSH password. This is why ansible myhost -m ping succeeds.
* Privilege Escalation (--become): Asks the Linux operating system inside the target host to elevate master or proxyman to root via sudo

To allow --become to run seamlessly alongside your SSH keys, grant NOPASSWD privileges in /etc/sudoers.d/ansible on each target host.

* On 10.68.68.50:

```bash
echo "master ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
sudo chmod 0440 /etc/sudoers.d/ansible
```

On 10.68.68.51:

```bash
echo "proxyman ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
sudo chmod 0440 /etc/sudoers.d/ansible
```

on 192.168.10.70:

```bash
cd ansible_quickstart

ansible myhost -m command -a "whoami" -i inventory.ini --become
```

Log

```log
[WARNING]: Host '10.68.68.51' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
10.68.68.51 | CHANGED | rc=0 >>
root
[WARNING]: Host '10.68.68.50' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
10.68.68.50 | CHANGED | rc=0 >>
root
```
### 4.1 Why This Is the Correct Security Model

1. Direct Root SSH Login Is Disabled: You connect over SSH as a standard, unprivileged user (master on 10.68.68.50 and proxyman on 10.68.68.51). This allows you to enforce PermitRootLogin no in SSH configurations across Zone 2.5 and Zone 2.
2. Elevated Execution on Demand: When you pass --become, Ansible connects as your unprivileged user and executes the task elevated via sudo. The whoami command running inside that elevated context correctly reports root
3. Required for System Provisioning: Day-2 tasks—such as formatting datadrive1, modifying AppArmor rules, running apt-get, and configuring zabbix-proxy systemd services—require root privileges on the target hosts.

Supress warning

```bash
# Version: 1.0.0
# Description: Configures target hosts and explicit Python interpreter path in inventory.ini

cat << 'EOF' > inventory.ini
[myhost]
10.68.68.50 ansible_user=master ansible_python_interpreter=/usr/bin/python3
10.68.68.51 ansible_user=proxyman ansible_python_interpreter=/usr/bin/python3
EOF
```

```bash
ansible myhost -m command -a "whoami" -i inventory.ini --become
```

Log
```log
10.68.68.51 | CHANGED | rc=0 >>
root
10.68.68.50 | CHANGED | rc=0 >>
root
```


Check the actual Ubuntu OS version and system specs gathered on-the-fly:

```bash
ansible myhost -m setup -a "filter=ansible_distribution*" -i inventory.ini
```

Ensure you can check syslog/journalctl activity ad-hoc:

```bash
ansible myhost -m command -a "tail -n 3 /var/log/syslog" -i inventory.ini --become
```

## 5. Ansible playbooks Start building playbooks for real world scenarios TODO


```bash
cd ansible_quickstart

```

https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html#playbooks-intro



## KVM snapshots and environment

A running environment with zabbix and mysql on one server and zabbix proxy on a different server.

```bash
sudo virsh snapshot-list ubuntu-zabbix01
Name                            Creation Time               State
----------------------------------------------------------------------
clean_install_zabbix_with_ssl   2026-10-24 01:03:17 +0200   running
 
 
sudo virsh domifaddr ubuntu-zabbix01
Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
vnet0      52:54:00:11:22:33    ipv4         10.68.68.50/24

# 

sudo virsh snapshot-list ubuntu-zabbix02
Name                         Creation Time               State
-------------------------------------------------------------------
clean-install                2026-10-23 17:31:04 +0200   running
clean_install_zabbix_proxy   2026-10-31 13:35:10 +0100   running

sudo virsh domifaddr ubuntu-zabbix02
Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
vnet1      52:54:00:11:22:34    ipv4         10.68.68.51/24
```

## Working with playbooks Gemini Research Purdue Model 3 ways automation = in progress

GOTO Playbooks

```bash
# ubuntu-zabbix02 has ufw enabled to behave like offline
ssh proxyman@10.68.68.51
# Disable it for this test
sudo ufw disable

cd ansible_quickstart/

# View inventory
ansible-inventory -i inventory.ini --list

# ping the host
ansible myhost -m ping -i inventory.ini 

# Playbook ping
ansible-playbook -i inventory.ini ping_hosts.yml

# Version: 1.0.0
# Description: Installs baseline tools and ensures timezone is set across sandbox nodes
ansible-playbook -i inventory.ini install_baseline_tools.yml

# Version: 1.0.0
# Description: Executes the system date command on target hosts and displays the output.
ansible-playbook -i inventory.ini get_date.yml

```


Add a folder

```bash
ansible-playbook -i inventory.ini add_folder.yml
```

The task failed the second time with a red error because raw Linux commands like mkdir are not idempotent. When mkdir /op_ansible executes on a host where /op_ansible already exists, the Linux system returns an error code (rc: 1), causing Ansible to report a task failure.

```yml
# Version: 1.0.0
# Description: Executes the mkdir command on target hosts and displays the output.

- name: Get Target System Date
  hosts: myhost
  become: true
  tasks:
    - name: Execute mkdir command
      ansible.builtin.command: mkdir /op_ansible
      register: system_date

    - name: Print folder creation message to console
      ansible.builtin.debug:
        msg: "Folder created on {{ inventory_hostname }}"
```

To get clean, green (ok) output when re-running playbooks, replace raw shell commands with native Ansible modules like ansible.builtin.file. Native modules inspect the target system first: if the directory already exists, Ansible makes no changes and reports ok (green) instead of crashing.

```yml
# Version: 1.1.0
# Description: Ensures directory exists idempotently using the native file module

- name: Manage Target System Directory
  hosts: myhost
  become: true
  tasks:
    - name: Ensure /op_ansible directory exists
      ansible.builtin.file:
        path: /op_ansible
        state: directory
        mode: '0755'
```

Add a folder

```bash
ansible-playbook -i inventory.ini add_folder.yml
```

Log

```txt
PLAY [Manage Target System Directory] **********************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [10.68.68.51]
ok: [10.68.68.50]

TASK [Ensure /op_ansible directory exists] *****************************************************************************
ok: [10.68.68.51]
ok: [10.68.68.50]

PLAY RECAP *************************************************************************************************************
10.68.68.50                : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.68.68.51                : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

### 1. You use ansible.builtin.file almost 100% of the time in production playbook

You use ansible.builtin.file almost 100% of the time in production playbooks, while ansible.builtin.command is reserved for specific edge cases.

* Use ansible.builtin.file whenever you need to create, modify, or remove files, directories, or symlinks.


```bash
# combine folder and file
# add a txt file to the folder we created

# That combination is standard production practice.
ansible-playbook -i inventory.ini add_folder_op_and_file.yml

```


### 2. To ensure a package is installed and its service is active and enabled on boot

```bash

# Version: 1.0.0
# Description: Ensures a package is installed and its systemd service is started and enabled on boot
ansible-playbook -i inventory.ini ensure_zabbix_agent2.yml


```




## Ansible tips and tricks documentation TODO READ

1.  Keep them lowercase, descriptive, and consistent; hyphens are a good choice. A clear pattern is verb + target or purpose, ending in .yml

https://docs.ansible.com/projects/ansible/latest/tips_tricks/index.html#playbooks-best-practices

## What more do we need to learn Gemini? TODO
