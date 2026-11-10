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
    - [3.1 Virtual Machine View and edit vms, ram, disk cpu](#31-virtual-machine-view-and-edit-vms-ram-disk-cpu)
    - [3.2 Virtual Machine increase ram](#32-virtual-machine-increase-ram)
    - [3.3 Virtual Machine increase disk todo](#33-virtual-machine-increase-disk-todo)
    - [3.4 Virtual Machine increase vcpu todo](#34-virtual-machine-increase-vcpu-todo)
    - [4. Virtual Machine Snapshots \& Restore](#4-virtual-machine-snapshots--restore)
    - [4.1 Remove vm and build new base IO/OT lab](#41-remove-vm-and-build-new-base-ioot-lab)
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

# To inspect the downloaded ISO images and virtual disk images (.qcow2) tracked inside each pool:
sudo virsh vol-list default

# Verification: Displays the downloaded installation ISOs (such as ubuntu-26.04-server.iso) and any root disk images located in /var/lib/libvirt/images/

# Verification: Displays disk images mounted on your 500GB drive at /mnt/datadrive1.
sudo virsh vol-list datadrive1-pool

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

# To view the active dynamic DHCP leases across a virtual network, run:
sudo virsh net-dhcp-leases test-network

# To list static IP host reservations configured in the network's XML definition, run:
sudo virsh net-dumpxml test-network | grep -i "ip='"
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

### 3.1 Virtual Machine View and edit vms, ram, disk cpu


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

### 3.2 Virtual Machine increase ram

```bash

sudo virsh shutdown ubuntu-test

sudo virsh setmaxmem ubuntu-test 4G --config

# Increase the Maximum Memory limit
sudo virsh setmem ubuntu-test 4G --config

# Increase the Current Memory allocation to match

sudo virsh start ubuntu-test

virsh dominfo ubuntu-test

```

### 3.3 Virtual Machine increase disk todo

### 3.4 Virtual Machine increase vcpu todo

### 4. Virtual Machine Snapshots & Restore

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


# 6 Remove all traces of the vm

# shutdown --domain vmname

sudo virsh shutdown --domain ubuntu-cloud-init01

# Remove configuration and associated disk storage
sudo virsh undefine --domain ubuntu-cloud-init01

# Force stop (the transient VM vanishes from virsh list automatically)
sudo virsh destroy ubuntu-cloud-init01

# remove all storage
sudo virsh undefine ubuntu-cloud-init01 --remove-all-storage

# Manually delete the disk file
# sudo rm -f /var/lib/libvirt/images/ubuntu-cloud-init01.qcow2

# check ip
sudo virsh net-dumpxml test-network | grep -i "10.68.68.60"

# Remove the static DHCP host reservation from test-network
sudo virsh net-update test-network delete ip-dhcp-host \
  "<host mac='52:54:00:11:22:35' name='ubuntu-cloud-init01' ip='10.68.68.60'/>" \
  --live --config
```


### 4.1 Remove vm and build new base IO/OT lab


```bash

sudo virsh destroy zabbix01

sudo virsh snapshot-list zabbix01
sudo virsh snapshot-delete zabbix01 clean-install-os

sudo virsh undefine zabbix01 --nvram
sudo rm -f /mnt/datadrive1/qemu/images/zabbix01.qcow2

sudo qemu-img create -f qcow2 /mnt/datadrive1/qemu/images/zabbix01.qcow2 20G

bash create_vms_static_zabbix01.sh

# verify console login first

# remove old
ssh-keygen -f '/home/master/.ssh/known_hosts' -R '10.68.68.50'
# add new
ssh-copy-id master@10.68.68.50

# The error sudo: interactive authentication is required occurs because the Ansible ad-hoc command defaults to trying privilege escalation (become: true or equivalent depending on your ansible.cfg defaults) for user execution, but passwordless sudo (NOPASSWD) is not configured for the master user on the freshly built zabbix01 host.

# Log into zabbix01 and add a sudoers rule allowing the master user to run sudo commands without a password prompt:

echo "master ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/master
sudo chmod 440 /etc/sudoers.d/master

# Re-run the Ansible Ad-Hoc Command

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