#!/bin/bash
# Version: 1.0.0
# Script to deploy a headless Ubuntu 26.04 VM using virt-install and serial console

sudo virt-install \
  --name ubuntu-test \
  --ram 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/ubuntu-test.qcow2,size=20,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=default,model=virtio \
  --graphics none \
  --location /var/lib/libvirt/images/ubuntu-26.04-server.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'