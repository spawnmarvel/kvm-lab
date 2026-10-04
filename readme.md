# kvm-lab

## Table of content

- [](#)
  - [Table of content](#table-of-content)
  - [Kernel Virtual Machine](#kernel-virtual-machine)
  - [KVM hypervisor a beginners’ guide](#kvm-hypervisor-a-beginners-guide)
  - [Lab Setup Strategy for AZ-800 \& AZ-801](#lab-setup-strategy-for-az-800--az-801)
  - [Step 1: Ubuntu 2604 setup](#step-1-ubuntu-2604-setup)
  - [Step 2: Format and mount the 500gb hdd devsda](#step-2-format-and-mount-the-500gb-hdd-devsda)
  - [Step 3: Install KVM, Libvirt, and Virt-Manager](#step-3-install-kvm-libvirt-and-virt-manager)
  - [Overview & Milestone Achieved](#overview--milestone-achieved)
  - [Download the Windows Server 2022 evaluation ISO directly to my new storage pool](#download-the-windows-server-2022-evaluation-iso-directly-to-my-new-storage-pool)
  - [Step 1: Create Dedicated Virtual Network (az800-lab)](#step-1-create-dedicated-virtual-network-az800-lab)
  - [Toplogy](#toplogy)
  - [Study guide for Exam AZ-800: Administering Windows Server Hybrid Core Infrastructure](#study-guide-for-exam-az-800-administering-windows-server-hybrid-core-infrastructure)
  - [virsh commands](#virsh-commands)
  - [Added 8 GB of DDR4 RAM](#added-8-gb-of-ddr4-ram)
  - [Pre step make a Ubuntu 26.04](#pre-step-make-a-ubuntu-2604)
  - [Step-by-Step GUI Creation Guide for DC01](#step-by-step-gui-creation-guide-for-dc01)

## Kernel Virtual Machine

Linux KVM (Kernel-based Virtual Machine) is a built-in open-source feature that turns your Linux kernel into a high-performance hypervisor

https://linux-kvm.org/page/Main_Page

KVM hypervisor enables full virtualisation capabilities. It provides each VM with all typical services of the physical system, including virtual BIOS (basic input/output system) and virtual hardware, such as processor, memory, storage, network cards, etc. As a result, every VM completely simulates a physical machine.


![tolplogy](https://github.com/spawnmarvel/kvm-lab/blob/main/images/topology.jpg)

## KVM hypervisor a beginners’ guide

Read and compare with gemini chat KVM AZ-800 & AZ-801 https://ubuntu.com/blog/kvm-hyphervisor

We just need to satisfy AZ-800 & AZ-801.

* DC01 (Domain Controller / DNS / DHCP): Windows Server 2022 Core or Desktop Experience (2 GB RAM).
* SVR01 (Member Server / File Services / Azure Arc / Storage Bus Cache): Windows Server 2022 (3 GB RAM).
* HV01 (Hyper-V Host for AZ-801 Labs): Windows Server 2022 with Hyper-V role enabled via nested virtualization (4–6 GB RAM).
* Host OS (Ubuntu): Leaves ~5–7 GB RAM for Ubuntu and management tools (Azure CLI, PowerShell Core, Windows Admin Center via browser).

## Lab Setup Strategy

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



Front
![hp](https://github.com/spawnmarvel/kvm-lab/blob/main/images/hp.png)

Back
![hp back](https://github.com/spawnmarvel/kvm-lab/blob/main/images/hp_back.png)

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


## Step 1: Create Dedicated Virtual Network (az800-lab)


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

### Toplogy

```txt
+---------------------------------------------------------------------------------+
|                         PHYSICAL HOST (Ubuntu 24.04 LTS)                        |
|                         HP ProDesk 600 G3 SFF                                   |
|                                                                                 |
|  [ Physical NIC ] <---> Home Network / Router <---> Internet                    |
|          |                                                                      |
|  [ /mnt/datadrive1 ] (500GB HDD Storage Pool: datadrive1-pool)                  |
|          ├── SERVER_EVAL_x64FRE_en-us.iso (Windows Server 2022 ISO - 4.7 GB)     |
|          └── vms/ (Storage location for .qcow2 virtual disks)                   |
|                                                                                 |
|  [ Virtual Bridge Interface: virbr1 ]                                           |
|          ├── IP Address: 192.168.100.1 /24 (Gateway / Router)                   |
|          ├── NAT Engine: Forwards outgoing traffic through Physical NIC          |
|          └── DHCP Service: Active (.100 to .200 pool)                            |
+---------------------------------------------------------------------------------+
                                       |
                                       | (Virtual Network Switch: az800-lab)
                                       v
===================================================================================
                    VIRTUAL NETWORK SUBNET: 192.168.100.0/24
===================================================================================
                                       |
                   +-------------------+-------------------+
                   | (Planned Deployment)                  | (Future Additions)
                   v                                       v
         +-------------------+                   +-------------------+
         | DC01 (Windows)    |                   | Member Servers    |
         | Target IP:        |                   | (FS01, SVR02,     |
         | 192.168.100.10/24 |                   |  Admin Workstation)
         +-------------------+                   +-------------------+
``` 


## Study guide for Exam AZ-800: Administering Windows Server Hybrid Core Infrastructure

https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-800

## virsh commands


GOTO readme.virsh_bash.md

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


## Pre step make a Ubuntu 26.04

Just to get a feel for it.



## Step-by-Step GUI Creation Guide for DC01

DC01 is the standard default hostname for a primary Active Directory (AD) domain controller in Windows Server environments. It runs 

* Active Directory Domain Services (AD DS)
* DNS to manage user authentication, group policies, and domain security.


