# virsh commands

## Table of content

- [virsh commands](#virsh-commands)
  - [Table of content](#table-of-content)
  - [virsh man](#virsh-man)
  - [libvirt.org](#libvirtorg)
  - [1. Pool and vnets](#1-pool-and-vnets)
  - [2. Vm's and ip addresses](#2-vms-and-ip-addresses)
  - [8 Linux virsh subcommands for managing VMs on the command line](#8-linux-virsh-subcommands-for-managing-vms-on-the-command-line)
  - [quick guide reference](#quick-guide-reference)


## virsh man

```bash

# virsh - management user interface
virsh --help

man virsh

``` 

## libvirt.org

https://www.libvirt.org/manpages/virsh.html

## 1. Pool and vnets

What we already used


```bash
v1.0.0
# Reference guide of virsh commands used for KVM virtual network and VM lifecycle management

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

# Define, build, and start a directory-based storage pool on a dedicated drive
virsh pool-define-as datadrive1-pool dir --target /mnt/datadrive1
virsh pool-build datadrive1-pool
virsh pool-start datadrive1-pool
virsh pool-autostart datadrive1-pool

# List all created virtual disk volumes inside a storage pool
virsh vol-list datadrive1-pool

``` 

## 2. Vm's and ip addresses

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

## 8 Linux virsh subcommands for managing VMs on the command line

```bash

```

* https://www.redhat.com/en/blog/virsh-subcommands


## quick guide reference

```bash

``` 

All references

https://www.libvirt.org/manpages/virsh.html