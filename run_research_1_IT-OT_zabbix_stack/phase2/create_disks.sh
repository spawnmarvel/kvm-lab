#!/bin/bash
# Version: 1.0.0
# Creates VM storage directories and qcow2 disk files on /mnt/datadrive1

sudo mkdir -p /mnt/datadrive1/qemu/images

# Create OS disks for the target stack
sudo qemu-img create -f qcow2 /mnt/datadrive1/qemu/images/ansiblectr01.qcow2 20G
sudo qemu-img create -f qcow2 /mnt/datadrive1/qemu/images/zabbix01.qcow2 20G
sudo qemu-img create -f qcow2 /mnt/datadrive1/qemu/images/mysql01.qcow2 20G
sudo qemu-img create -f qcow2 /mnt/datadrive1/qemu/images/zabbix02.qcow2 20G

# Create dedicated 30GB volume for mysql01 datadrive1
sudo qemu-img create -f qcow2 /mnt/datadrive1/qemu/images/mysql01-datadrive1.qcow2 30G