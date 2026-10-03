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
-
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
* 16 GB Ram (DDR4)
* 256 GB SSD, 500 GB HDD
* Image ubuntu-26.04.1-desktop-amd64
* Rufus
* Scandisk USB stick


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

