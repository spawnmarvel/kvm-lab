#!/bin/bash
# Version: 2.0.0
# Script to deploy headless Ubuntu 26.04 VM via standard ISO install

# Define deployment target IP
ip="10.68.68.60"

deploy_vm() {
  echo "Deploying Ubuntu 26.04 VM..."

  # 1. Add static reservation for a unique MAC on test-network
  sudo virsh net-update test-network add-last ip-dhcp-host \
    "<host mac='52:54:00:11:22:35' name='ubuntu-cloud-init01' ip='$ip'/>" \
    --live --config

  # 2. Deploy VM with standard serial console
  sudo virt-install \
    --name ubuntu-cloud-init01 \
    --ram 4096 \
    --vcpus 2 \
    --disk path=/var/lib/libvirt/images/ubuntu-cloud-init01.qcow2,size=20,bus=virtio,format=qcow2 \
    --os-variant ubuntu24.04 \
    --network network=test-network,model=virtio,mac=52:54:00:11:22:35 \
    --graphics none \
    --location /var/lib/libvirt/images/ubuntu-26.04-server.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
    --extra-args 'console=ttyS0,115200n8 serial'
}

# Check if the IP exists in the libvirt network XML
check_ip=$(sudo virsh net-dumpxml test-network | grep -i "$ip")

if [ -n "$check_ip" ]; then
  echo "IP address $ip is already reserved in test-network. Please choose a different IP."
  exit 1
else
  echo "IP address $ip is available."

  read -p "Do you want to proceed with VM creation? [y/N]: " choice
  choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

  if [[ "$choice" == "y" || "$choice" == "yes" ]]; then
    deploy_vm
  else
    echo "Action cancelled."
  fi
fi

# master, justfortest1
