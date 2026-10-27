#!/bin/bash
# Version: 1.4.0
# Script to deploy a fully automated headless Ubuntu 26.04 VM with autoinstall via cloud-init

# 1. Add static reservation for a unique MAC on test-network
sudo virsh net-update test-network add-last ip-dhcp-host \
  "<host mac='52:54:00:11:22:35' name='ubuntu-cloud-init01' ip='10.68.68.60'/>" \
  --live --config

# 2. Deploy VM with non-interactive autoinstall kernel arguments
sudo virt-install \
  --name ubuntu-cloud-init01 \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/ubuntu-cloud-init01.qcow2,size=20,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=test-network,model=virtio,mac=52:54:00:11:22:35 \
  --graphics none \
  --location /var/lib/libvirt/images/ubuntu-26.04-server.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial autoinstall ds=nocloud;s=/cidata/ quiet ---' \
  --cloud-init user-data=user-data.yaml

# master, justfortest1