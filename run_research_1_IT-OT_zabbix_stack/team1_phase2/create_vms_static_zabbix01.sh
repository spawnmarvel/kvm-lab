#!/bin/bash
# Version: 1.0.0
# Description: Registers static DHCP reservation and launches zabbix01 VM installation

ISO_PATH="/var/lib/libvirt/images/ubuntu-26.04-server.iso"

sudo virsh net-update zone25-idmz add-last ip-dhcp-host \
  "<host mac='52:54:00:68:68:50' name='zabbix01' ip='10.68.68.50'/>" \
  --live --config 2>/dev/null || true

sudo virt-install \
  --name zabbix01 \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/mnt/datadrive1/qemu/images/zabbix01.qcow2,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=zone25-idmz,model=virtio,mac=52:54:00:68:68:50 \
  --graphics none \
  --location ${ISO_PATH},kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'