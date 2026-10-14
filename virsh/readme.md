# virsh commands

## Table of content

- [virsh commands](#virsh-commands)
  - [Table of content](#table-of-content)
  - [virsh (enter, help)](#virsh-enter-help)
  - [virsh man, help and interactive terminal](#virsh-man-help-and-interactive-terminal)
  - [libvirt.org](#libvirtorg)
  - [1. Pool's](#1-pools)
  - [2. Vnets](#2-vnets)
  - [3. Vm's (domain) and ip addresses](#3-vms-domain-and-ip-addresses)
  - [3. View and edit vms, ram, disk cpu](#3-view-and-edit-vms-ram-disk-cpu)
    - [3.1 Increase ram](#31-increase-ram)
  - [8 Linux virsh subcommands for managing VMs on the command line](#8-linux-virsh-subcommands-for-managing-vms-on-the-command-line)
  - [quick guide reference](#quick-guide-reference)


## virsh (enter, help) 


```bash
virsh

Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh #

start help
edit help
list help
help pool-list

# you get the idea

exit
```

## virsh man, help and interactive terminal

```bash

# virsh - management user interface
virsh --help

man virsh


virsh
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh #

``` 


## libvirt.org

https://www.libvirt.org/manpages/virsh.html

## 1. Pool's


```bash
# Define, build, and start a directory-based storage pool on a dedicated drive
virsh pool-define-as datadrive1-pool dir --target /mnt/datadrive1
virsh pool-build datadrive1-pool
virsh pool-start datadrive1-pool
virsh pool-autostart datadrive1-pool

# List all created virtual disk volumes inside a storage pool
virsh vol-list datadrive1-pool

``` 

## 2. Vnets

```bash

# List all active and inactive virtual networks
virsh net-list --all

# Create and start a virtual network from an XML configuration file
virsh net-define az800-lab.xml
virsh net-start az800-lab

# Set a virtual network to automatically start on host boot
virsh net-autostart az800-lab

# Inspect detailed configuration and status of a virtual network
virsh net-info az800-lab
virsh net-dumpxml az800-lab

# List all virtual machine storage pools and their status
virsh pool-list --all

```

## 3. Vm's (domain) and ip addresses

In virsh, a domain is a virtualized guest abstraction, such as a virtual machine (VM) or container managed via libvirt.

* Domain Name (e.g., my-vm)
* Domain ID (a numeric ID used only while the guest is running)
* Domain UUID (a unique Universally Unique Identifier string)

```bash

# List all virtual machines currently defined on the host
sudo virsh list --all

# stop
sudo virsh shutdown ubuntu-vm2

# rename
sudo virsh domrename ubuntu-vm2 ubuntu-test
# start

# edit configuration (must check what ww can edit, but move between networks is fine)
sudo virsh edit ubuntu-test

# start
sudo virsh start ubuntu-test


# check if it has autostart
# Look for the Autostart line in the output. It will explicitly show either enable or disable
sudo virsh dominfo ubunty-test


# get vm ip

sudo virsh domifaddr ubuntu-test

 Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
 vnet5      52:54:00:11:22:33    ipv4         10.68.68.50/24

# You can verify which virtual network ubuntu-test is attached to directly from your host's terminal using
# Sequential Allocation: Every time a VM starts, stops, re-instantiates, 
# or has its virtual network adapter re-attached, the Linux kernel 
# assigns the next available vnetX integer index on the host.
sudo virsh domiflist ubuntu-test

 Interface   Type      Source         Model    MAC
------------------------------------------------------------------
 vnet5       network   test-network   virtio   52:54:00:11:22:33

# Run this single command on your host terminal to stop the VM, unregister it from libvirt
sudo virsh destroy ubuntu-test --graceful 2>/dev/null || sudo virsh destroy ubuntu-test

# automatically delete its storage disk
sudo virsh undefine ubuntu-test --remove-all-storage
```

## 3. View and edit vms, ram, disk cpu


```bash


# Basic RAM and CPU allocation, ++
virsh dominfo ubuntu-test

# Detailed vCPU configuration
virsh vcpuinfo ubuntu-test

# Live memory statistics 
virsh dommemstat ubuntu-test

# Live CPU and memory usage overview
virsh domstats ubuntu-test --cpu-total

# List attached block devices
# here we find the target we can use below
virsh domblklist ubuntu-test

# View capacity, allocation, and physical size in human-readable units
virsh domblkinfo ubuntu-test vda --human

```

### 3.1 Increase ram

```bash

sudo virsh shutdown ubuntu-test

sudo virsh setmaxmem ubuntu-test 4G --config

# Increase the Maximum Memory limit
sudo virsh setmem ubuntu-test 4G --config

# Increase the Current Memory allocation to match

sudo virsh start ubuntu-test

virsh dominfo ubuntu-test

```

## 8 Linux virsh subcommands for managing VMs on the command line

```bash

```

* https://www.redhat.com/en/blog/virsh-subcommands


## quick guide reference

```bash

``` 

All references

https://www.libvirt.org/manpages/virsh.html