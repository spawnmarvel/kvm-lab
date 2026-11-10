# Ansibel quickguide

## Table of content

- [Ansibel quickguide](#ansibel-quickguide)
  - [Table of content](#table-of-content)
  - [azure-ansibel quickguide back in 2023](#azure-ansibel-quickguide-back-in-2023)
  - [Ansible docs](#ansible-docs)
  - [Core Concepts](#core-concepts)
  - [Key Advantages](#key-advantages)
  - [Ansible Agentless Architecture Linux and Windows](#ansible-agentless-architecture-linux-and-windows)
  - [Essential Ansible concepts](#essential-ansible-concepts)
  - [Getting Started with Ansible: A Beginner’s Guide](#getting-started-with-ansible-a-beginners-guide)
  - [Inventory](#inventory)
  - [SSH key-based authentication](#ssh-key-based-authentication)
    - [host\_key\_checking ansible.cfg](#host_key_checking-ansiblecfg)
  - [Ansible Ad-hoc commands](#ansible-ad-hoc-commands)
  - [Enable Native Logging](#enable-native-logging)
    - [OS-Level Auditing](#os-level-auditing)
    - [Verify yaml](#verify-yaml)
  - [Playbooks --check with --diff and or --limit and or --syntax-check](#playbooks---check-with---diff-and-or---limit-and-or---syntax-check)
  - [Semaphore UI](#semaphore-ui)

## azure-ansibel quickguide back in 2023

Testing and learning Ansibel with Azure

* Create vms linyc and windows
* Playbook roles, When to turn a playbook into a role
* Semaphore UI
* mariadb, wordpress, apache, grafana etc
* Lots of gold here

* https://github.com/spawnmarvel/azure-ansible


## Ansible docs

https://docs.ansible.com/projects/ansible/latest/getting_started/index.html

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

## Essential Ansible concepts

https://developers.redhat.com/learning/learn:ansible:foundations-ansible/resource/resources:essential-ansible-concepts

## Getting Started with Ansible: A Beginner’s Guide

https://dev.to/anushree_gm/getting-started-with-ansible-a-beginners-guide-3deh

## Inventory

```bash
ssh espenk@192.168.10.70
mkdir mkdir io_ot_lab_build
```

## SSH key-based authentication

### host_key_checking ansible.cfg



## Ansible Ad-hoc commands

## Enable Native Logging

* Remove vars_prompt and shell appends: Keep your playbooks fully idempotent and automated.

* Enable Native Logging: If you want a local file log on the control node or managed nodes for debugging, configure Ansible's global callback or log output in ansible.cfg rather than writing manual tasks:

The file /opt/ansible/automation.log is located locally on the Ansible control node (ansiblectr01), not on the remote managed nodes (zabbix01, zabbix02, or mysql01).

If Ansible hasn't created the file yet, it is usually because the /opt/ansible directory does not exist or the executing user (master) lacks write permissions to /opt/ansible. You can create it and set ownership on the control node with:

```bash

sudo mkdir -p /opt/ansible
sudo chown master:master /opt/ansible

# run to confirm the directory exists and is owned by your user.
ls -ld /opt/ansible
```

```ini
[defaults]
log_path = /opt/ansible/automation.log
```

### OS-Level Auditing

OS-Level Auditing: For package installations and system modifications, Linux already maintains authoritative logs in /var/log/apt/history.log, /var/log/dpkg.log, and the system journal (journald), which can be collected by Zabbix or forwarded to a log aggregator (like Loki).


### Verify yaml

https://www.yamllint.com/

## Playbooks --check with --diff and or --limit and or --syntax-check

Combine --check with --diff to see a before-and-after text comparison of any configuration files that would be modified:


```bash
ansible-playbook playbook.yml --check

ansible-playbook playbook.yml --check --diff
# To safely run a check or dry-run update across your nodes using Ansible limits, you can use Ansible's --check flag combined with --limit. This allows you to inspect what changes would occur without actually writing any packages to disk.
ansible-playbook -i inventory/hosts.ini playbooks/update_apt.yml --limit mysql01 --check

# when all works out on each one, you can run all or just one and one
ansible-playbook -i inventory/hosts.ini playbooks/update_apt.yml --limit mysql01

# syntax check, If the playbook has valid YAML formatting and correct Ansible structure, the command returns the playbook path and exits with return code 0
ansible-playbook -i inventory/hosts.ini playbooks/mount_datadrive.yml --syntax-check
```


## Semaphore UI

Semaphore UI gives your team one self-hosted place to run, share, schedule, secure, and audit operational workflows.

Use Semaphore UI with Ansible, Terraform, OpenTofu, Terragrunt, Bash, PowerShell, and Python, while keeping your automation in Git and your existing toolchain intact.

* https://semaphoreui.com/

