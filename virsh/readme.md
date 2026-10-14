# virsh commands

## Table of content

- [virsh commands](#virsh-commands)
  - [Table of content](#table-of-content)
  - [virsh (enter, help)](#virsh-enter-help)
  - [virsh man, help and interactive terminal](#virsh-man-help-and-interactive-terminal)
  - [libvirt.org](#libvirtorg)
  - [1. Storage Pools](#1-storage-pools)
  - [2. Vnets](#2-vnets)
  - [3. Virtual Machines (Domains) and ip addresses](#3-virtual-machines-domains-and-ip-addresses)
  - [3. Virtual Machine View and edit vms, ram, disk cpu](#3-virtual-machine-view-and-edit-vms-ram-disk-cpu)
    - [3.1 Increase ram](#31-increase-ram)
    - [Virtual Machine Snapshots \& Restore](#virtual-machine-snapshots--restore)
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

## 1. Storage Pools


```bash
# Define, build, and start a directory-based storage pool on a dedicated drive
sudo virsh pool-define-as datadrive1-pool dir --target /mnt/datadrive1

# Build, start, and set autostart for the pool
sudo virsh pool-build datadrive1-pool
sudo virsh pool-start datadrive1-pool
sudo virsh pool-autostart datadrive1-pool

# List all created virtual disk volumes inside a storage pool
sudo virsh vol-list datadrive1-pool

# Refresh pool after placing ISOs or disk images
sudo virsh pool-refresh datadrive1-pool

# List all virtual machine storage pools and their status
sudo virsh pool-list --all

``` 

## 2. Vnets

For the test-network GOTO\scripts_network

```bash

# Create and navigate to network scripts directory
mkdir -p ~/scripts_networks
cd ~/scripts_networks

# 1. Register the network configuration with libvirt (adjust path if needed)
sudo virsh net-define ~/scripts_networks/test-network.xml

# 2. Start the network bridge interface
sudo virsh net-start test-network

# 3. Configure it to autostart on system boot
sudo virsh net-autostart test-network

# Inspect detailed configuration and status of a virtual network
sudo virsh net-info test-network
sudo virsh net-dumpxml test-network

# List all active and inactive virtual networks
sudo virsh net-list --all


```

## 3. Virtual Machines (Domains) and ip addresses

In virsh, a domain is a virtualized guest abstraction, such as a virtual machine (VM) or container managed via libvirt.

* Domain Name (e.g., my-vm)
* Domain ID (a numeric ID used only while the guest is running)
* Domain UUID (a unique Universally Unique Identifier string)



For deploy vm GOTO \scripts_kvm

```bash

# Create and navigate to KVM deployment scripts directory
mkdir -p ~/scripts_kvm
cd ~/scripts_kvm

# Create and run deployment script
nano create-ubuntu-vm.sh
chmod +x create-ubuntu-vm.sh
./create-ubuntu-vm.sh

# List all virtual machines on the host
sudo virsh list --all

# Stop VM before renaming (VM MUST be shut down to rename)
sudo virsh shutdown ubuntu-vm2

# Rename VM
sudo virsh domrename ubuntu-vm2 ubuntu-test

# Edit VM configuration XML schema, we have change vnet, not sure about more, read docs
sudo virsh edit ubuntu-test

# Start VM
sudo virsh start ubuntu-test

# Inspect VM domain info (verify autostart status)
sudo virsh dominfo ubuntu-test

# Enable/Disable VM autostart on host boot
sudo virsh autostart ubuntu-test
# sudo virsh autostart --disable ubuntu-test

# Get guest IP address assigned via libvirt DHCP
sudo virsh domifaddr ubuntu-test

# Verify virtual interface and attached network
sudo virsh domiflist ubuntu-test

# Stop VM gracefully (or force stop if hung)
sudo virsh destroy ubuntu-test --graceful 2>/dev/null || sudo virsh destroy ubuntu-test

# Unregister VM and permanently delete its storage disk
sudo virsh undefine ubuntu-test --remove-all-storage




```

## 3. Virtual Machine View and edit vms, ram, disk cpu


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

### Virtual Machine Snapshots & Restore

```bash
# list all domains / vms
sudo virsh list --all

# start if not running
sudo virsh start ubuntu-test

# 1. Create a named snapshot with description
sudo virsh snapshot-create-as --domain ubuntu-test --name "clean-install-snap-1" --description "Clean baseline setup before testing"

# 2. List all snapshots for a VM
sudo virsh snapshot-list --domain ubuntu-test

# RESTORE

# View details of the current active snapshot
sudo virsh snapshot-list --domain ubuntu-test

# 4. Revert VM back to a specific snapshot and ensure it runs
# revert, --running: Forces the VM to boot immediately into the running state upon reverting
sudo virsh snapshot-revert --domain ubuntu-test --snapshotname clean-install-snap-1 --running

# verify
sudo virsh list --all

# Inspect current snapshot metadata state
sudo virsh snapshot-current --domain ubuntu-test --name

# 5. Delete a snapshot when no longer needed
sudo virsh snapshot-delete --domain ubuntu-test --snapshotname clean-install-snap
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