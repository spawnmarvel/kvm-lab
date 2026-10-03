# kvm-lab

## Table of content

- [](#)
  - [Table of content](#table-of-content)
  - [Kernel Virtual Machine](#kernel-virtual-machine)
  - [KVM hypervisor a beginners’ guide](#kvm-hypervisor-a-beginners-guide)
  - [Lab Setup Strategy for AZ-800 \& AZ-801](#lab-setup-strategy-for-az-800--az-801)

## Kernel Virtual Machine

Linux KVM (Kernel-based Virtual Machine) is a built-in open-source feature that turns your Linux kernel into a high-performance hypervisor

https://linux-kvm.org/page/Main_Page

KVM hypervisor enables full virtualisation capabilities. It provides each VM with all typical services of the physical system, including virtual BIOS (basic input/output system) and virtual hardware, such as processor, memory, storage, network cards, etc. As a result, every VM completely simulates a physical machine.


![tolplogy](https://github.com/spawnmarvel/todo-and-current/blob/main/bash_linux_kvm_hypervisor/images/topology.jpg)

## KVM hypervisor a beginners’ guide

Start by grabbing a fresh physical or virtual machine (yes, you can do nested virtualisation) with 

* 4+ core amd64 CPU
* 16 GB of RAM
* 50 GB of storage 
* and the latest Ubuntu Server LTS installed

Read and compare with gemini chat KVM AZ-800 & AZ-801 https://ubuntu.com/blog/kvm-hyphervisor

We just need to satisfy AZ-800 & AZ-801.

* DC01 (Domain Controller / DNS / DHCP): Windows Server 2022 Core or Desktop Experience (2 GB RAM).
* SVR01 (Member Server / File Services / Azure Arc / Storage Bus Cache): Windows Server 2022 (3 GB RAM).
* HV01 (Hyper-V Host for AZ-801 Labs): Windows Server 2022 with Hyper-V role enabled via nested virtualization (4–6 GB RAM).
* Host OS (Ubuntu): Leaves ~5–7 GB RAM for Ubuntu and management tools (Azure CLI, PowerShell Core, Windows Admin Center via browser).

## Lab Setup Strategy for AZ-800 & AZ-801

* Old laptop with 2 ram slots each 8gb ddr3 ram.
* Image ubuntu-26.04.1-desktop-amd64
* Rufus
* Scandisk USB stick


1. Insert a USB Flash Drive: Connect a USB drive (at least 8 GB) to your laptop. Note that flashing will erase all existing data on the flash drive.
2. Open Rufus (if on Windows), select the downloaded ubuntu-26.04.1-desktop-amd64.iso, 
3. choose GPT / UEFI (non CSM), and click START
4. Boot Laptop from USB: Restart your laptop, press your device’s boot menu key (typically F12, F11, or Del), select the USB drive, and begin installing Ubuntu.

![rufus](https://github.com/spawnmarvel/todo-and-current/blob/main/bash_linux_kvm_hypervisor/images/rufus.png)