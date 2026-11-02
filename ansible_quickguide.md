# Ansibel quickguide

## Table of content

- [Ansibel quickguide](#ansibel-quickguide)
  - [Table of content](#table-of-content)
  - [Ansible docs](#ansible-docs)
  - [Core Concepts](#core-concepts)
  - [Key Advantages](#key-advantages)
  - [Ansible Agentless Architecture Linux and Windows](#ansible-agentless-architecture-linux-and-windows)
  - [Essential Ansible concepts](#essential-ansible-concepts)
  - [Getting Started with Ansible: A Beginner’s Guide](#getting-started-with-ansible-a-beginners-guide)
  - [Inventory](#inventory)
  - [SSH key-based authentication](#ssh-key-based-authentication)
  - [Ansible Ad-hoc commands](#ansible-ad-hoc-commands)
  - [Playbooks](#playbooks)


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

## Ansible Ad-hoc commands

## Playbooks




