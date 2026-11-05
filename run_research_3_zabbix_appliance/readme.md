# Zabbix Appliance

## Table of content

- [Zabbix Appliance](#zabbix-appliance)
  - [Table of content](#table-of-content)
  - [Zabbix appliance 7.0](#zabbix-appliance-70)
  - [Overview](#overview)
    - [System requirements:](#system-requirements)

## Zabbix appliance 7.0

## Overview

As an alternative to setting up manually or reusing an existing server for Zabbix, users may download a Zabbix appliance or a Zabbix appliance installation CD image.

Zabbix appliance and installation CD versions are based on AlmaLinux 8 (x86_64).

Zabbix appliance installation CD can be used for instant deployment of Zabbix server (MySQL).

 >[!WARNING] The Appliance is not intended for serious production use.

https://www.zabbix.com/download_appliance#70LTS




### System requirements:

RAM: 4 GB
Disk space: at least 8 GB should be allocated for the virtual machine
CPU: 2 cores minimum

Zabbix appliance contains a Zabbix server (configured and running on MySQL) and a frontend.

Zabbix virtual appliance is available in the following formats:

* VMware (.vmx)
* Open virtualization format (.ovf)
* Microsoft Hyper-V (.vhd / .vhdx)
* KVM, Parallels, QEMU, USB stick, VirtualBox, Xen (.raw)
* KVM, QEMU (.qcow2)

To get started, boot the appliance and point a browser at the IP the appliance has received over DHCP.

https://www.zabbix.com/documentation/7.0/en/manual/appliance
