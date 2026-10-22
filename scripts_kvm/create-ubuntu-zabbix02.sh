#!/bin/bash
# Version: 1.1.0
# Script to deploy a headless Ubuntu 26.04 VM (ubuntu-zabbix02) attached to test-network via serial console

# 1. Add static reservation for a unique MAC on test-network
sudo virsh net-update test-network add-last ip-dhcp-host \
  "<host mac='52:54:00:11:22:34' name='ubuntu-zabbix02' ip='10.68.68.51'/>" \
  --live --config

# 2. Deploy the VM using the matching MAC address
sudo virt-install \
  --name ubuntu-zabbix02 \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/ubuntu-zabbix02.qcow2,size=20,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=test-network,model=virtio,mac=52:54:00:11:22:34 \
  --graphics none \
  --location /var/lib/libvirt/images/ubuntu-26.04-server.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'

  # proxy, justfortest1