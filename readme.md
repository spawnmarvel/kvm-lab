# kvm-lab

## Table of content

- [kvm-lab](#kvm-lab)
  - [Table of content](#table-of-content)
  - [Kernel Virtual Machine](#kernel-virtual-machine)
  - [Azure vs KVM](#azure-vs-kvm)
  - [What is hypervisor?](#what-is-hypervisor)
  - [KVM hypervisor a beginners’ guide](#kvm-hypervisor-a-beginners-guide)
    - [1. KVM hypervisor benefits](#1-kvm-hypervisor-benefits)
    - [2. What is KVM and tools](#2-what-is-kvm-and-tools)
  - [Lab Setup Strategy HP ProDesk 600 G3 SFF i7 6.gen](#lab-setup-strategy-hp-prodesk-600-g3-sff-i7-6gen)
    - [Step 1: Ubuntu 26.04 setup](#step-1-ubuntu-2604-setup)
    - [Step 2: Format and Mount the 500GB HDD (/dev/sda)](#step-2-format-and-mount-the-500gb-hdd-devsda)
    - [Step 3: Install KVM, Libvirt, and Virt-Manager](#step-3-install-kvm-libvirt-and-virt-manager)
    - [Overview \& Milestone Achieved](#overview--milestone-achieved)
  - [Download the Windows Server 2022 evaluation ISO directly to my new storage pool](#download-the-windows-server-2022-evaluation-iso-directly-to-my-new-storage-pool)
    - [Step 1: Create Dedicated Virtual Network via GUI (example)](#step-1-create-dedicated-virtual-network-via-gui-example)
  - [Step 1.1 Create Dedicated Virtual Network test-network via virsh 10.68.68.0/24 (254 addresses total)](#step-11-create-dedicated-virtual-network-test-network-via-virsh-106868024-254-addresses-total)
    - [1. The Subnet Boundaries (10.68.68.0/24):](#1-the-subnet-boundaries-106868024)
    - [2. The Dynamic DHCP Range (10.68.68.2 – 10.68.68.20):](#2-the-dynamic-dhcp-range-1068682--10686820)
    - [3. Static IPs outside the DHCP range (10.68.68.21 – 10.68.68.254):](#3-static-ips-outside-the-dhcp-range-10686821--106868254)
    - [Toplogy](#toplogy)
  - [Study guide for Exam AZ-800: Administering Windows Server Hybrid Core Infrastructure](#study-guide-for-exam-az-800-administering-windows-server-hybrid-core-infrastructure)
  - [virsh commands](#virsh-commands)
  - [Added 8 GB of DDR4 RAM](#added-8-gb-of-ddr4-ram)
  - [Get to know Virtual Machine Manager GUI / na...we go headless, look below](#get-to-know-virtual-machine-manager-gui--nawe-go-headless-look-below)
  - [UFW (Uncomplicated Firewall) with KVM GUI Gufw](#ufw-uncomplicated-firewall-with-kvm-gui-gufw)
  - [Get to know Virtual Machine Manager with virsh via ssh / or headless](#get-to-know-virtual-machine-manager-with-virsh-via-ssh--or-headless)
    - [Managing KVM Storage Pools \& Locations via CLI](#managing-kvm-storage-pools--locations-via-cli)
    - [Steps 1–3: Inspect Storage Pools \& Directories](#steps-13-inspect-storage-pools--directories)
    - [Step 4: Download Ubuntu 26.04 ISO](#step-4-download-ubuntu-2604-iso)
    - [Step 5: Create the Headless VM (virt-install) with static ip](#step-5-create-the-headless-vm-virt-install-with-static-ip)
      - [There is a lot of steps, keep default and enable ssh](#there-is-a-lot-of-steps-keep-default-and-enable-ssh)
    - [Step 6: SSH into the VM](#step-6-ssh-into-the-vm)
    - [Step 7: Netplan Static IP Configuration verify 10.68.68.50](#step-7-netplan-static-ip-configuration-verify-10686850)
      - [Why 10.68.68.50 Is Not Listed in Netplan](#why-10686850-is-not-listed-in-netplan)
  - [Analyzing Your Current DNS Setup](#analyzing-your-current-dns-setup)
    - [Order of Precedence in Ubuntu DN](#order-of-precedence-in-ubuntu-dn)
  - [Backup and restore](#backup-and-restore)

## Kernel Virtual Machine

Linux KVM (Kernel-based Virtual Machine) is a built-in open-source feature that turns your Linux kernel into a high-performance hypervisor

https://linux-kvm.org/page/Main_Page

## Azure vs KVM

While Azure abstracts away physical infrastructure maintenance, with KVM you are the cloud provider:


* No Automatic Control Plane: You manage storage allocation, free memory space, CPU overcommit ratios, and host disk space directly.

* Storage Performance: In Azure, you select a Premium SSD SKU. In KVM, you choose disk caching modes (none, writethrough, writeback), storage formats (qcow2 vs raw), and raw block devices (LVM/NVMe passthrough).

* Network Plumbing: Azure manages virtual switches behind the scenes. In KVM, you manually create host bridges, map physical NICs, or set up VLAN sub-interfaces on the host OS.

Learning KVM completes the full infrastructure abstraction stack for you.

KVM fills the critical layer directly in the middle—the hypervisor and virtualization substrate. It turns what used to be "cloud magic" into explicit, visible Linux processes and kernel mechanisms.


What KVM Unlocks in Your Knowledge Base


```txt
[ Your Azure Skillset ]        --->  Higher-level Cloud Abstraction & Governance
       │
       ▼
[ KVM / Libvirt Layer ]        --->  THE MISSING LINK (CPU Virtualization, QEMU, TAP Devices)
       │
       ▼
[ Your Linux & Net Skillset ]  --->  Host OS Kernel, Hardware, Network Topologies & Services

```

With KVM under your belt, you transition from someone who manages virtual environments to someone who understands the entire lifecycle of a workload.


1. Bare Metal Hardware & Kernel: CPU extensions, memory management, PCI buses, physical NICs.

2. Hypervisor & Process Control: KVM modules, QEMU device emulation, libvirt daemon, cgroups, namespaces.

3. Guest OS & Services: Linux/Windows kernel, systemd, networking stack, certificate stores, local storage.

4. Applications & Monitoring: RabbitMQ, MySQL, Python services, Zabbix agents, Prometheus exporters.

5. Cloud Infrastructure & Orchestration: Azure VNets, IAM, ARM templates, hybrid connectivity.

## What is hypervisor?

A hypervisor, or virtual machine monitor (VMM), is software, firmware, or hardware that creates and runs virtual machines by splitting a physical computer's resources among multiple operating systems

KVM hypervisor enables full virtualisation capabilities. It provides each VM with all typical services of the physical system, including virtual BIOS (basic input/output system) and virtual hardware, such as processor, memory, storage, network cards, etc. As a result, every VM completely simulates a physical machine.


## KVM hypervisor a beginners’ guide

### 1. KVM hypervisor benefits

1. Native Linux

2. Performance –  Since KVM is the type-1 hypervisor, it outperforms all type-2 hypervisors, ensuring near-metal performance.

3. Scalability – As a Linux kernel module, the KVM hypervisor automatically scales to respond to heavy loads once the number of VMs increases. 

4. Security – Since KVM is part of the Linux kernel source code, it benefits from the world’s biggest open source community collaboration

5. Maturity – KVM was first created in 2006 and has continued to be actively developed since then. 

6. Cost-efficiency – Last but not least, cost is a driving factor for many organisations. Since KVM is open source and available as a Linux kernel module, it comes at zero cost out of the box.

https://ubuntu.com/blog/kvm-hyphervisor

![tolplogy](https://github.com/spawnmarvel/kvm-lab/blob/main/images/topology.jpg)

### 2. What is KVM and tools

Kernel-based Virtual Machine (KVM) is an open source virtualization technology for Linux® operating systems. 

With KVM, Linux can function as a hypervisor that runs multiple, isolated virtual machines (VMs).


libvirt and virsh

The libvirt project provides an API for managing virtualization platforms. Within libvirt, virsh is a command-line utility for creating, starting, listing, and stopping VMs, as well as entering a virtualization shell.


Virtual Machine Manager

Virtual Machine Manager (known as VMM or virt-manager) provides a desktop interface for VMs, and is available for major Linux distributions.

[...]


https://www.redhat.com/en/topics/virtualization/what-is-KVM


## Lab Setup Strategy HP ProDesk 600 G3 SFF i7 6.gen

* HP ProDesk 600 G3 SFF i7 6.gen
* CPU's 8
* 16 GB Ram (DDR4), (We will upgrade to 24GB a bit later)
* Slot Count:  4 memory slots on the motherboard
* Maximum Capacity: Up to 64 GB total, 16 GB each, you can mix 4, 8, 16
* 256 GB SSD, 500 GB HDD
* Image ubuntu-26.04.1-desktop-amd64
* Rufus
* Scandisk USB stick


The HP ProDesk 600 G3 SFF with a 6th-generation Intel Core i7 processor (specifically the i7-6700) is highly capable and well-suited for KVM (Kernel-based Virtual Machine) hypervisors like Proxmox VE, Ubuntu Server, or pure QEMU/KVM.

While it features older hardware, it serves as an excellent, budget-friendly machine for a home lab or lightweight virtualization server.


bios

* Virtualization Technology (VTx): Checked (enables core KVM hardware acceleration for running 64-bit VMs)
* Virtualization Technology for Directed I/O (VTd): Checked (enables direct PCI device passthrough capabilities)

Additionally, Hyperthreading and Multi-processor support are both enabled, allowing KVM/libvirt to utilize all 8 threads of your Core i7-7700

![bios](https://github.com/spawnmarvel/kvm-lab/blob/main/images/bios.png)


Front

![hp](https://github.com/spawnmarvel/kvm-lab/blob/main/images/hp.png)

Back

![hp back](https://github.com/spawnmarvel/kvm-lab/blob/main/images/hp_back.png)



In the future maybe this HP ProDesk 400 G9 SFF 9H7L1ET stasjonær PC

* https://www.power.no/data-og-tilbehoer/pc-og-mac/bedrifts-pc/stasjonaer-pc-bedrift/hp-prodesk-400-g9-sff-9h7l1et-stasjonaer-pc/p-4171257/


```txt

The Intel Core i5-14500 in this G9 SFF is an absolute monster for virtualization compared to your i7-7700:

``` 

1. Insert a USB Flash Drive: Connect a USB drive (at least 8 GB) to your laptop. Note that flashing will erase all existing data on the flash drive.
2. Open Rufus (if on Windows), select the downloaded ubuntu-26.04.1-desktop-amd64.iso, 
3. choose GPT / UEFI (non CSM), and click START
4. Boot Laptop from USB: Restart your laptop, press your device’s boot menu key (typically F12, F11, or Del), select the USB drive, and begin installing Ubuntu.

![rufus](https://github.com/spawnmarvel/kvm-lab/blob/main/images/rufus.png)

### Step 1: Ubuntu 26.04 setup

```bash
hostnamectl
``` 

Result:

```log
Static hostname: kvm-host-HP-ProDesk-600-G3-SFF
        Icon name: computer-desktop
          Chassis: desktop 🖥️
Chassis Asset Tag: CZC8417B8V
       Machine ID: 65b6409fa9c54edb8e83bbadbaf03a8e
          Boot ID: e7787f400fee49d19c6671e35227d827
 Operating System: Ubuntu 26.04.1 LTS              
           Kernel: Linux 7.0.0-38-generic
     Architecture: x86-64
  Hardware Vendor: HP
   Hardware Model: HP ProDesk 600 G3 SFF
     Hardware SKU: Y3F34AV
 Hardware Version: KBC Version 06.29
 Firmware Version: P07 Ver. 02.51
    Firmware Date: Thu 2024-07-18
     Firmware Age: 2y 2month 2w 2d    
```

```bash
# get ram
free -h
cat /proc/meminfo | grep MemTotal

# get disk
lsblk

# get cpu
lscpu
``` 

Result:

```log
MemTotal:       15718592 kB

NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0     4K  1 loop /snap/bare/5
loop1         7:1    0  66.8M  1 loop /snap/core24/1643
loop2         7:2    0    20M  1 loop /snap/desktop-security-center/151
loop3         7:3    0 260.3M  1 loop /snap/firefox/8763
loop4         7:4    0  16.5M  1 loop /snap/firmware-updater/226
loop5         7:5    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop6         7:6    0 614.5M  1 loop /snap/gnome-46-2404/164
loop7         7:7    0   1.5M  1 loop /snap/hwctl/123
loop8         7:8    0   402M  1 loop /snap/mesa-2404/1839
loop9         7:9    0  18.8M  1 loop /snap/prompting-client/222
loop10        7:10   0  50.1M  1 loop /snap/snapd/27710
loop11        7:11   0  11.8M  1 loop /snap/snap-store/1390
loop12        7:12   0   828K  1 loop /snap/snapd-desktop-integration/391
sda           8:0    0 465.8G  0 disk 
├─sda1        8:1    0    16M  0 part 
└─sda2        8:2    0 465.7G  0 part 
nvme0n1     259:0    0 238.5G  0 disk 
├─nvme0n1p1 259:1    0     1G  0 part /boot/efi
└─nvme0n1p2 259:2    0 237.4G  0 part /


Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             39 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      8
  On-line CPU(s) list:       0-7
Vendor ID:                   GenuineIntel
  Model name:                Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz
    CPU family:              6
    Model:                   94
    Thread(s) per core:      2
    Core(s) per socket:      4
    Socket(s):               1

```

### Step 2: Format and Mount the 500GB HDD (/dev/sda)


```bash
# Create a new GPT label and format /dev/sda into a single ext4 partition:
sudo parted -s /dev/sda mklabel gpt
sudo parted -s /dev/sda mkpart primary ext4 0% 100%
sudo mkfs.ext4 -F /dev/sda1
``` 

Create the target folder and retrieve the volume's UUID:

```bash
sudo mkdir -p /mnt/datadrive1
DISK_UUID=$(sudo blkid -s UUID -o value /dev/sda1)
echo "Retrieved UUID: $DISK_UUID"

```
Retrieved UUID: c7a67a1a-d67a-4fdf-9497-00a1d79e0032


Configure /etc/fstab and Mount the Drive


```bash
echo "UUID=c7a67a1a-d67a-4fdf-9497-00a1d79e0032 /mnt/datadrive1 ext4 defaults 0 2" | sudo tee -a /etc/fstab

sudo mount -a

systemctl daemon-reload

# verify
df -h /mnt/datadrive1
``` 
datadrive1

```log
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       458G  2.1M  435G   1% /mnt/datadrive1
```

By default, newly formatted drives mounted under /mnt are owned by root. Change the ownership to your user account espenk:

```bash
sudo chown -R espenk:espenk /mnt/datadrive1
mkdir -p /mnt/datadrive1/vms /mnt/datadrive1/iso
```

Check heat

```bash
sudo apt install lm-sensors

sudo sensors-detect

sensors

```

Result

```log
radeon-pci-0100
Adapter: PCI adapter
temp1:        +46.0°C  (crit = +120.0°C, hyst = +90.0°C)
freq1:        875 MHz 

nvme-pci-0200
Adapter: PCI adapter
Composite:    +26.9°C  (low  = -20.1°C, high = +77.8°C)
                       (crit = +81.8°C)
Sensor 1:     +26.9°C  (low  = -273.1°C, high = +65261.8°C)

coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +33.0°C  (high = +84.0°C, crit = +100.0°C)
Core 0:        +30.0°C  (high = +84.0°C, crit = +100.0°C)
Core 1:        +30.0°C  (high = +84.0°C, crit = +100.0°C)
Core 2:        +30.0°C  (high = +84.0°C, crit = +100.0°C)
Core 3:        +29.0°C  (high = +84.0°C, crit = +100.0°C)

hp-isa-0000
Adapter: ISA adapter
pwm1:             N/A

``` 

### Step 3: Install KVM, Libvirt, and Virt-Manager


* We will install the KVM hypervisor stack (qemu-kvm, libvirt, virt-manager)
* Add your user (espenk) to the appropriate system groups so you don't need sudo for virtual machine operations, 
* Then define /mnt/datadrive1 as an active storage pool in libvirt.


***Install Hypervisor & Tools***

Update package repositories and install the KVM engine, libvirt daemon, network tools, and Virt-Manager GUI:

```bash
sudo apt update

kvm-ok

INFO: /dev/kvm exists
KVM acceleration can be used


# In newer Ubuntu releases, qemu-kvm is a transitional 
# virtual package replaced by qemu-system-x86

sudo apt install -y qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils virt-manager
```

***Configure User Groups & Enable Service***


```bash
# Add your user account espenk to the libvirt
# and kvm groups and enable the service:
sudo usermod -aG libvirt,kvm espenk

sudo systemctl enable --now libvirtd

# verify libvrtd
sudo systemctl status libvirtd

``` 

Log

```log
 libvirtd.service - libvirt legacy monolithic daemon
     Loaded: loaded (/usr/lib/systemd/system/libvirtd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-10-03 22:10:42 CEST; 45s ago
```

***Define Storage Pool on 500GB HDD***

```bash
# Reload your group permissions using su:
su - $USER

virsh pool-define-as datadrive1-pool dir --target /mnt/datadrive1
# Pool datadrive1-pool defined


virsh pool-build datadrive1-pool
# Pool datadrive1-pool built

virsh pool-start datadrive1-pool
# Pool datadrive1-pool started

virsh pool-autostart datadrive1-pool
# Pool datadrive1-pool marked as autostarted

# Check active libvirt storage pools:
virsh pool-list --all
```

Log

```log
 Name              State    Autostart
---------------------------------------
 datadrive1-pool   active   yes
```

### Overview & Milestone Achieved

Your libvirt storage pool datadrive1-pool is now fully defined, started, and set to autostart! This completes the host setup on your HP ProDesk 600 G3 SFF.

With KVM installed and /mnt/datadrive1 active as a storage pool, you can launch virt-manager at any time to visually monitor and control your VMs.

![virtual manager](https://github.com/spawnmarvel/kvm-lab/blob/main/images/virt_manager.png)


To permanently grant virt-manager access across all desktop applications and menus:

Log out of Ubuntu and log back in (or reboot the host machine)

```bash
sudo reboot
``` 

After rebooting, launch Virtual Machine Manager from your desktop app menu or by typing virt-manager in any terminal—it will connect to qemu:///system without errors.


![qemu](https://github.com/spawnmarvel/kvm-lab/blob/main/images/qemu.png)

Once virt-manager opens, you will see qemu:///system connected with datadrive1-pool ready under Edit -> Connection Details -> Storage!


![qemu storage](https://github.com/spawnmarvel/kvm-lab/blob/main/images/qemu_storage.png)

## Download the Windows Server 2022 evaluation ISO directly to my new storage pool


We will download the official Microsoft Windows Server 2022 64-bit Evaluation ISO directly into your ISO folder on /mnt/datadrive1/iso using wget.

Once downloaded, we will refresh datadrive1-pool so virt-manager instantly recognizes the ISO file for VM deployments.


Download the official 64-bit English evaluation ISO directly from Microsoft (~4.7 GB):


Visit and register.

https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022

Please select your Windows Server 2022 download

* ISO downloads 64 bit edition > SERVER_EVA_x64FRE_en-us.iso 4.7 GB


```bash

# Delete all contents inside the iso folder if any
sudo rm -rf /mnt/datadrive1/iso/*

# Ensure directory permissions are clean for espenk
sudo chown -R espenk:espenk /mnt/datadrive1
chmod 755 /mnt/datadrive1

cd Downloads

cp SERVER_EVAL_x64FRE_en-us.iso /mnt/datadrive1/iso/SERVER_EVAL_x64FRE_en-us.iso

cd /mnt/datadrive1

ls
# SERVER_EVAL_x64FRE_en-us.iso

# Ensure proper permissions
chmod 644 SERVER_EVAL_x64FRE_en-us.iso

# It should show a file size of approximately 4.7 GB.
ls -lh /mnt/datadrive1/SERVER_EVAL_x64FRE_en-us.iso 

# Refresh libvirt storage pool
virsh pool-refresh datadrive1-pool
virsh vol-list datadrive1-pool


```

Log

```log
 Name                           Path
------------------------------------------------------------------------------
 iso                            /mnt/datadrive1/iso
 lost+found                     /mnt/datadrive1/lost+found
 SERVER_EVAL_x64FRE_en-us.iso   /mnt/datadrive1/SERVER_EVAL_x64FRE_en-us.iso
 vms                            /mnt/datadrive1/vms


``` 

With the storage layer validated, the next step is to create the dedicated virtual network switch for the AZ-800 lab and deploy the first Windows Server 2022 virtual machine (DC01).


### Step 1: Create Dedicated Virtual Network via GUI (example)


Define a dedicated virtual network (az800-lab) on subnet 192.168.100.0/24. This gives your Active Directory Domain Controller and subsequent lab VMs an isolated communication channel with outbound NAT access.

```bash

cat << 'EOF' > ~/az800-lab-network.xml
<network>
  <name>az800-lab</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.100.100' end='192.168.100.200'/>
    </dhcp>
  </ip>
</network>
EOF
```

Or in GUI.


![vnet](https://github.com/spawnmarvel/kvm-lab/blob/main/images/vnet.png)

1. Click the Finish (or Apply) button at the bottom right of the wizard window.
2. Ensure the newly created az800-lab network is selected in the left list and click the green Play/Start button (if it isn't already active).
3. Check the Autostart checkbox so the virtual switch turns on automatically when your Ubuntu host boots up.


![vnet active](https://github.com/spawnmarvel/kvm-lab/blob/main/images/vnet_active.png)


```bash
virsh net-list --all
``` 

Log

```log
 Name        State    Autostart   Persistent
----------------------------------------------
 az800-lab   active   yes         yes
 default     active   yes         yes
```

To quickly view the bridge name and basic network details:

```bash
virsh net-info az800-lab
``` 

To print the full XML configuration showing the exact gateway IP (192.168.100.1) and DHCP pool range (.100 to .200):

```bash
virsh net-dumpxml az800-lab | grep -A 5 "<ip"
``` 

Or get xml from GUI

```xml
<network>
  <name>az800-lab</name>
  <uuid>371919da-e36b-486b-aaa5-3e9064562c9a</uuid>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535"/>
    </nat>
  </forward>
  <bridge name="virbr1" stp="on" delay="0"/>
  <mac address="52:54:00:17:15:e4"/>
  <domain name="az800-lab"/>
  <ip address="192.168.100.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.100.100" end="192.168.100.200"/>
    </dhcp>
  </ip>
</network>

``` 

* Name, az800lab
* uuid, A unique identifier generated automatically by libvirt to track this network internally.
* <forward mode="nat">, Network Address Translation. Gives your VMs internet access through your host's physical network adapter, while keeping the VMs hidden from the rest of your physical home network.
* <nat><port .../></nat>, Defines the standard unprivileged port range the host uses to translate outgoing traffic for the VMs.
* <bridge name="virbr1">, The virtual network bridge created inside Linux. stp="on" prevents network loops, and delay="0" ensures virtual switch ports forward packets instantly on boot.
* <mac address="...">, The virtual MAC address assigned to the host gateway interface (virbr1).
* <domain name="...">, Sets the local DNS search domain suffix assigned to VMs connected to this virtual switch.
* <ip address="..." netmask="...">, Host Gateway IP. Your Ubuntu host acts as the router/gateway for this private subnet (192.168.100.0/24). VMs will use 192.168.100.1 as their Default Gateway.


192.168.100.0/24

* Total IP addresses: $2^8 = 256
* Network Address: 192.168.100.0 (Reserved)Broadcast Address: 192.168.100.255 (Reserved)
* Host Gateway IP: 192.168.100.1 (Assigned to your Ubuntu host bridge virbr1)

This leaves 253 usable IP addresses (192.168.100.2 through 192.168.100.254).


## Step 1.1 Create Dedicated Virtual Network test-network via virsh 10.68.68.0/24 (254 addresses total)



```bash

mkdir networks
cd networks

```
Create it on current folder

```bash
cat << 'EOF' > test-network.xml
<network>
  <name>test-network</name>
  <forward mode='nat'/>
  <bridge name='virbr2' stp='on' delay='0'/>
  <ip address='10.68.68.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.68.68.2' end='10.68.68.20'/>
    </dhcp>
  </ip>
</network>
EOF
```
Import, launch, and enable autostart on host boot for:

``` bash
# 1. Register the network configuration with libvirt
sudo virsh net-define ~/test-network.xml

# 2. Start the network bridge interface
sudo virsh net-start test-network

# 3. Configure it to autostart on system boot
sudo virsh net-autostart test-network

```

Verification:

```bash

# 1. List all libvirt networks and their autostart status
sudo virsh net-list --all

 Name           State    Autostart   Persistent
-------------------------------------------------
 az800-lab      active   yes         yes
 default        active   yes         yes
 test-network   active   yes         yes


# Inspect the host's virbr2 bridge interface
ip addr show virbr2

7: virbr2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:45:08:40 brd ff:ff:ff:ff:ff:ff
    inet 10.68.68.1/24 brd 10.68.68.255 scope global virbr2
       valid_lft forever preferred_lft forever
```

Active Configuration File Locations

```bash
cd /etc/libvirt/qemu
ls
networks

cd networks
ls
autostart  az800-lab.xml  default.xml  test-network.xml
```


In the test-network configuration (10.68.68.0/24), you defined the DHCP scope with the following parameters:

* Host Gateway / Bridge IP (virbr2): 10.68.68.1 (1 IP)
* DHCP Range: 10.68.68.2 through 10.68.68.20

This gives you 19 dynamically assignable IP addresses available in the DHCP pool for your virtual machines.


***Why 10.68.68.50 Works (Static IP vs Dynamic Scope)***

The key distinction is between dynamic DHCP pool allocation and static IP assignment within the /24 subnet:

### 1. The Subnet Boundaries (10.68.68.0/24):

* Subnet Mask: 255.255.255.0 (/24)

* Total Usable Host Addresses: 10.68.68.1 through 10.68.68.254 (254 addresses total).

* Gateway (virbr2): 10.68.68.1.

### 2. The Dynamic DHCP Range (10.68.68.2 – 10.68.68.20):

* This range is reserved strictly for unrecognized devices or generic dynamic DHCP requests.

* When an unknown device asks for an IP, dnsmasq hands out an address between .2 and .20.

### 3. Static IPs outside the DHCP range (10.68.68.21 – 10.68.68.254):

* Address 10.68.68.50 is inside the 10.68.68.0/24 network, so routing, gateways, and internet access work seamlessly.

* Because .50 sits outside the dynamic scope (.2–.20), dnsmasq will never automatically hand it out to another random VM. That makes it completely safe from IP conflicts.




### Toplogy


![topolgy net](https://github.com/spawnmarvel/kvm-lab/blob/main/images/toplogy_net.png)



```txt
+---------------------------------------------------------------------------------+
|                         PHYSICAL HOST (Ubuntu 24.04 LTS)                        |
|                         HP ProDesk 600 G3 SFF                                   |
|                                                                                 |
|  [ Physical NIC: eno1 ] <---> Home Network / Router <---> Internet              |
|          |                                                                      |
|  [ Storage Pool: default ] (/var/lib/libvirt/images)                            |
|          ├── ubuntu-26.04-server.iso (Ubuntu ISO Image)                         |
|          └── ubuntu-test.qcow2 (Virtual Disk for guest VM)                      |
|                                                                                 |
|  [ Virtual Bridge Interface: virbr2 ]                                           |
|          ├── IP Address: 10.68.68.1 /24 (Gateway / Router)                      |
|          ├── NAT Engine: Forwards outgoing traffic through Physical NIC (eno1)   |
|          └── DHCP Service: Active (10.68.68.2 to 10.68.68.20 pool)              |
+---------------------------------------------------------------------------------+
                                       |
                                       | (Virtual Network Switch: test-network)
                                       v
===================================================================================
                    VIRTUAL NETWORK SUBNET: 10.68.68.0/24
===================================================================================
                                       |
                   +-------------------+-------------------+
                   | (Dynamic DHCP Zone)                   | (Static / Reserved Zone)
                   | Range: 10.68.68.2 - 10.68.68.20       | Range: 10.68.68.21 - 10.68.68.254
                   v                                       v
         +-------------------+                   +-------------------+
         | Generic / Test    |                   | ubuntu-test       |
         | Unrecognized VMs  |                   | MAC:              |
         | (Auto DHCP IP)    |                   | 52:54:00:11:22:33 |
         +-------------------+                   | Static IP:        |
                                                 | 10.68.68.50/24    |
                                                 +-------------------+
``` 


## Study guide for Exam AZ-800: Administering Windows Server Hybrid Core Infrastructure

https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-800

## virsh commands


GOTO virsh

## Added 8 GB of DDR4 RAM

```bash
free -h

```
Log

```log
               total        used        free      shared  buff/cache   available
Mem:            22Gi       1.2Gi        20Gi        75Mi       1.1Gi        21Gi
Swap:          4.0Gi          0B       4.0Gi

```   


HP ProDesk 600 G3 SFF RAM, NVME, GPU, CPU Upgrade 2023

* https://www.youtube.com/watch?v=-HbeV6Lbj6s&t=44s

1. Remove main 
2. Remove side with the power off button
3. The unplug the two black and click here and lift like a car door that goes up

![click](https://github.com/spawnmarvel/kvm-lab/blob/main/images/click.jpg)

All slots are full, from left (this is before insert the last 4gb)

1. 4GB, price 150nok / finn.no
2. 8GB
3. 4GB, price 150nok / finn.no
4. 8GB

![ram](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ram.jpg)


## Get to know Virtual Machine Manager GUI / na...we go headless, look below

Lets get to know the Virtual Machine Manager GUI before we start to use only virsh commands

1. Download ubuntu 26.04
2. Make a vm
3. Take a clean snap
4. Make some files, install something, connect to internet
5. Restore to the clean snap



## UFW (Uncomplicated Firewall) with KVM GUI Gufw


For running a KVM (Kernel-based Virtual Machine) virtualization host on Ubuntu, UFW (Uncomplicated Firewall) is the best and easiest default choice for host-level security, though nftables or libvirt's native integration handles the actual virtual bridge routing

Why UFW Works Well

• Pre-installed: It comes built-in with Ubuntu.

• Simple Syntax: It replaces complex iptables commands with plain English commands (e.g., sudo ufw allow ssh).

• KVM Compatibility: KVM and libvirt automatically insert their own forwarding rules into the underlying netfilter/iptables layer, and UFW can peacefully coexist as long as forwarding is enabled in /etc/ufw/ufw.conf (DEFAULT_FORWARD_POLICY="ACCEPT")


Gufw is the official graphical user interface for UFW on Ubuntu. It provides a clean, easy-to-use desktop window to manage your firewall rules without using the terminal.

```bash
sudo apt update && sudo apt install gufw

# either seacth for it Firewall Configuration, or type
gufw
```

Once installed, you can find it in your application menu by searching for "Firewall Configuration".

• Pre-configured Profiles: Easily toggle between Home, Office, and Public profiles.

• Simple Rule Creation: Add rules by choosing from predefined applications/ports or entering custom IP addresses.

• Live Logging: View blocked and allowed traffic in real-time to debug connectivity issues with your virtual machines.


Create new rule


Gufw

* https://manpages.ubuntu.com/manpages/focal/man8/gufw.8.html


You can do the same with commands.

![gufw](https://github.com/spawnmarvel/kvm-lab/blob/main/images/gufw.png)

## Get to know Virtual Machine Manager with virsh via ssh / or headless

### Managing KVM Storage Pools & Locations via CLI

Lets get to know the Virtual Machine Manager, we start to use only virsh commands

1. Inspect Active Storage Pools
2. Locate Storage Directories
3. List Storage Volumes
4. Download Debian 12 Image (Netinst ISO or Cloud Image)
5. Create the Ubuntu VM via Headless CLI (virt-install)
6. Steps to Obtain IP & SSH into the VM


Enter kvm-host-HP-ProDesk-600-G3-SFF

```bash
ssh

192.168.10.70
```

### Steps 1–3: Inspect Storage Pools & Directories


```bash
# 1. List active storage pools
sudo virsh pool-list --all

 Name              State    Autostart
---------------------------------------
 datadrive1-pool   active   yes
 default           active   yes


# 2. Locate storage pool physical directory (default path)
sudo virsh pool-info default

Name:           default
UUID:           3486f9fb-a93c-4457-9ca6-3f794cd49f49
State:          running
Persistent:     yes
Autostart:      yes
Capacity:       232.64 GiB
Allocation:     17.65 GiB
Available:      214.98 GiB

# 3. List existing storage volumes (virtual disks/ISOs)
sudo virsh vol-list default

 Name   Path
--------------

```


### Step 4: Download Ubuntu 26.04 ISO

```bash
# save images
cd /var/lib/libvirt/images

# get ubuntu 26.04
sudo wget https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.iso -O ubuntu-26.04-server.iso

# refrsh pool
sudo virsh pool-refresh default

# Verify that the ISO volume shows up in your storage pool:
sudo virsh vol-list default

 Name                      Path
----------------------------------------------------------------------------
 debian-12-netinst.iso     /var/lib/libvirt/images/debian-12-netinst.iso
 ubuntu-26.04-server.iso   /var/lib/libvirt/images/ubuntu-26.04-server.iso

```

### Step 5: Create the Headless VM (virt-install) with static ip

```bash

cd ~
pwd

/home/espenk

mkdir scripts
cd scripts

sudo nano create-ubuntu-vm.sh
```

GOTO Scripts\

```bash
# make it executable
chmod +x create-ubuntu-vm.sh

# run it
./create-ubuntu-vm.sh
```

If you do not assignd a static ip, any VM built will immediately draw its IP address from the test-network range (10.68.68.2–10.68.68.20) during installation



When you execute ./create-ubuntu-vm.sh, virt-install will start and connect your terminal directly to the Ubuntu text installer via the serial console. You can verify that the step was successful when the installer screen appears directly inside your SSH session.

Press Enter on [ Continue in rich mode > ]

Navigate through the installer prompts using your arrow keys, Tab, and Spacebar:

* Language & Keyboard: Select your preferred language and layout (e.g., English / Norwegian).
* Network Connections: Leave the default DHCP settings on the virbr0 interface.
* Storage Configuration: Accept the default guided layout on the 20 GB disk.
* Profile Setup: Enter your desired username, password, and hostname.
* SSH Setup: Make sure to check [X] Install OpenSSH server so you can connect via SSH later.
* Featured Snaps: Leave everything unchecked and press Done.
* Select Reboot Now when the installation completes.


(Note: To detach from the serial console at any time, press Ctrl + ]. Reconnect whenever you want using sudo virsh console ubuntu-test.)


![ubuntu1](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ubuntu1.png)

#### There is a lot of steps, keep default and enable ssh

john

lima

justfortest1

![ubuntu1_user](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ubuntu1_user.png)

![ubuntu1_ssh](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ubuntu1_ssh.png)

Select Reboot Now when the installation completes.

![ubuntu1_reboot](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ubuntu1_reboot.png)


Press enter

![ubuntu1_press_enter](https://github.com/spawnmarvel/kvm-lab/blob/main/images/ubuntu1_press_enter.png)

### Step 6: SSH into the VM

We assigned a static ip.

```bash
ssh john@10.68.68.50

hostname
lina

uname -a
Linux lima 7.0.0-38-generic #38-Ubuntu SMP PREEMPT_DYNAMIC Fri Sep  4 09:10:14 UTC 2026 x86_64 GNU/Linux

free -h
               total        used        free      shared  buff/cache   available
Mem:           1.6Gi       336Mi       996Mi       1.1Mi       455Mi       1.3Gi
Swap:          1.7Gi          0B       1.7Gi

lsblk
lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0                        11:0    1 1024M  1 rom
vda                       253:0    0   20G  0 disk
├─vda1                    253:1    0    1M  0 part
├─vda2                    253:2    0  1.8G  0 part /boot
└─vda3                    253:3    0 18.2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   10G  0 lvm  /


```


### Step 7: Netplan Static IP Configuration verify 10.68.68.50

Dynamic DHCP vs. IP Persistence
Short answer: It can change, but in practice with libvirt, it usually stays the same.

Lets have a look at netplan


```bash
cd /etc/netplan
ls
00-installer-config.yaml

cat 00-installer-config.yaml
```

Netplan

```yml
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: true
      match:
        macaddress: '52:54:00:11:22:33'
      set-name: enp1s0
  version: 2
```

#### Why 10.68.68.50 Is Not Listed in Netplan

You do not see 10.68.68.50 inside /etc/netplan/00-installer-config.yaml because the VM's guest OS is set to DHCP (dhcp4: true).

Instead of configuring a hardcoded static IP directly inside the guest operating system, your IP address is being managed externally by the libvirt DHCP server on the KVM host.

1. Host Reservation Rule: On the KVM host, you ran:

```bash
# we ran
./create-ubuntu-vm.sh

# [...]

# 1. Add static reservation for a specific MAC on test-network
sudo virsh net-update test-network add-last ip-dhcp-host \
  "<host mac='52:54:00:11:22:33' name='ubuntu-vm2' ip='10.68.68.50'/>" \
  --live --config
```

2. MAC Matching: During boot, ubuntu-test broadcasts a standard DHCP request over virtual interface enp1s0 using MAC address 52:54:00:11:22:33
3. Host Response: The host dnsmasq service intercepts the request, recognizes the MAC address 52:54:00:11:22:33, and assigns it the reserved static IP 10.68.68.50.

Because dhcp4: true is active, Netplan accepts 10.68.68.50 dynamically from the host.

This host reservation method is the standard industry best practice for automated lab deployments, as it avoids manual post-installation Netplan edits or frozen SSH sessions.


## Analyzing Your Current DNS Setup


resolved.conf is not used.

```bash

sudo cat /etc/systemd/resolved.conf
```

Result

```txt
#DNS=
#FallbackDNS=

```

Check DNS we are using, Yes, you are currently using the KVM host for DNS resolution.

Your resolvectl status output confirms that interface enp1s0 inside ubuntu-test has its Current DNS Server set to 10.68.68.1, which is the IP address of your host bridge (virbr2).



```bash
resolvectl status
Global
         Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
  resolv.conf mode: stub

Link 2 (enp1s0)
    Current Scopes: DNS
         Protocols: +DefaultRoute -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 10.68.68.1
       DNS Servers: 10.68.68.1
     Default Route: yes

```

Trace it with built in tool

```bash
tracepath google.com
```

Log

```log
tracepath google.com
 1?: [LOCALHOST]                      pmtu 1500
 1:  kvm-host-HP-ProDesk-600-G3-SFF                        0.366ms
 1:  kvm-host-HP-ProDesk-600-G3-SFF                        0.340ms
 2:  34D5091B3F50.lan                                      1.145ms
 [...] The rest is different for each network
 Hops 3–7
 Packet enters your fiber ISP network (Altibox/Lyse) and travels across the core routing network (latency stays tight between 4.6 ms and 13.9 ms).
```

To verify that packets are reaching Google despite the rate-limited probe responses, test direct HTTP/ICMP reachability:

```bash
# 1. ICMP ping check
ping -c 3 google.com

# 2. HTTP response check via curl
curl -I https://www.google.com
```


### Order of Precedence in Ubuntu DN

1. Top Priority — /etc/systemd/resolved.conf (Global Scope):

Any DNS servers listed under DNS= or FallbackDNS= in resolved.conf apply system-wide across all interfaces. They override or complement link-level settings.

2. Second Priority — Netplan Explicit Nameservers (nameservers.addresses):

DNS servers configured inside /etc/netplan/*.yaml apply directly to that specific network link (e.g., enp1s0).



## Backup and restore


Step 1: Create Initial Clean Snapshot / Disk Backup


Step 2: Modify Guest Files & System State


Step 3: Revert & Restore to Clean Baseline State


Step 4: Verification


