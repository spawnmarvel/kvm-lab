#!/bin/bash
# Version: 1.0.0
# Description: Registers static DHCP reservation and launches zabbix02 VM installation on Zone 2 OT

ISO_PATH="/var/lib/libvirt/images/ubuntu-26.04-server.iso"

sudo virsh net-update zone2-ot add-last ip-dhcp-host \
  "<host mac='52:54:00:68:20:15' name='zabbix02' ip='10.68.20.15'/>" \
  --live --config 2>/dev/null || true

sudo virt-install \
  --name zabbix02 \
  --ram 3048 \
  --vcpus 2 \
  --disk path=/mnt/datadrive1/qemu/images/zabbix02.qcow2,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=zone2-ot,model=virtio,mac=52:54:00:68:20:15 \
  --graphics none \
  --location ${ISO_PATH},kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'