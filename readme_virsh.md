# virsh commands

## Table of content


## virsh man

```bash

virsh --help

man virsh

``` 

## What we have used before we create the first vm

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

# List all virtual machines currently defined on the host
virsh list --all


``` 

## 8 Linux virsh subcommands for managing VMs on the command line

```bash

```

* https://www.redhat.com/en/blog/virsh-subcommands


## The virsh program is the main interface for managing virsh guest domains.

```bash

``` 

* https://www.libvirt.org/manpages/virsh.html