#!/bin/bash
# Version: 1.1.0
# Deploys target scenario VMs with static libvirt DHCP reservations and virt-install

ISO_PATH="/var/lib/libvirt/images/ubuntu-26.04-server.iso"

# 1. Add static DHCP reservations for Zone 2.5 iDMZ hosts
sudo virsh net-update zone25-idmz add-last ip-dhcp-host \
  "<host mac='52:54:00:68:68:10' name='ansiblectr01' ip='10.68.68.10'/>" \
  --live --config

sudo virsh net-update zone25-idmz add-last ip-dhcp-host \
  "<host mac='52:54:00:68:68:50' name='zabbix01' ip='10.68.68.50'/>" \
  --live --config

sudo virsh net-update zone25-idmz add-last ip-dhcp-host \
  "<host mac='52:54:00:68:68:52' name='mysql01' ip='10.68.68.52'/>" \
  --live --config

# 2. Add static DHCP reservation for Zone 2 OT Proxy host
sudo virsh net-update zone2-ot add-last ip-dhcp-host \
  "<host mac='52:54:00:68:20:15' name='zabbix02' ip='10.68.20.15'/>" \
  --live --config

# 3. Deploy ansiblectr01 (Zone 2.5 iDMZ)
sudo virt-install \
  --name ansiblectr01 \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/mnt/datadrive1/qemu/images/ansiblectr01.qcow2,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=zone25-idmz,model=virtio,mac=52:54:00:68:68:10 \
  --graphics none \
  --location ${ISO_PATH},kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'

# 4. Deploy zabbix01 (Zone 2.5 iDMZ)
sudo virt-install \
  --name zabbix01 \
  --ram 3072 \
  --vcpus 2 \
  --disk path=/mnt/datadrive1/qemu/images/zabbix01.qcow2,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=zone25-idmz,model=virtio,mac=52:54:00:68:68:50 \
  --graphics none \
  --location ${ISO_PATH},kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'

# 5. Deploy mysql01 (Zone 2.5 iDMZ) with secondary datadrive1 volume
sudo virt-install \
  --name mysql01 \
  --ram 3072 \
  --vcpus 2 \
  --disk path=/mnt/datadrive1/qemu/images/mysql01.qcow2,bus=virtio,format=qcow2 \
  --disk path=/mnt/datadrive1/qemu/images/mysql01-datadrive1.qcow2,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=zone25-idmz,model=virtio,mac=52:54:00:68:68:52 \
  --graphics none \
  --location ${ISO_PATH},kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'

# 6. Deploy zabbix02 (Zone 2 OT)
sudo virt-install \
  --name zabbix02 \
  --ram 2048 \
  --vcpus 2 \
  --disk path=/mnt/datadrive1/qemu/images/zabbix02.qcow2,bus=virtio,format=qcow2 \
  --os-variant ubuntu24.04 \
  --network network=zone2-ot,model=virtio,mac=52:54:00:68:20:15 \
  --graphics none \
  --location ${ISO_PATH},kernel=casper/vmlinuz,initrd=casper/initrd \
  --extra-args 'console=ttyS0,115200n8 serial'