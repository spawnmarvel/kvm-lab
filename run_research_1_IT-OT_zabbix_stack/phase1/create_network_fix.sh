#!/bin/bash
# Version: 1.0.1
# Description: Defines networks with correct routing mode for Purdue model inter-zone communication

cat << 'EOF' > zone25-idmz.xml
<network>
  <name>zone25-idmz</name>
  <forward mode='nat'/>
  <bridge name='virbr25' state='unknown'/>
  <ip address='10.68.68.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.68.68.100' end='10.68.68.200'/>
    </dhcp>
  </ip>
</network>
EOF

cat << 'EOF' > zone2-ot.xml
<network>
  <name>zone2-ot</name>
  <forward mode='route'/>
  <bridge name='virbr20' state='unknown'/>
  <ip address='10.68.20.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.68.20.100' end='10.68.20.200'/>
    </dhcp>
  </ip>
</network>
EOF

# Stop and undefine existing networks if already active
sudo virsh net-destroy zone25-idmz 2>/dev/null || true
sudo virsh net-undefine zone25-idmz 2>/dev/null || true
sudo virsh net-destroy zone2-ot 2>/dev/null || true
sudo virsh net-undefine zone2-ot 2>/dev/null || true

# Define, start, and enable autostart
sudo virsh net-define zone25-idmz.xml
sudo virsh net-start zone25-idmz
sudo virsh net-autostart zone25-idmz

sudo virsh net-define zone2-ot.xml
sudo virsh net-start zone2-ot
sudo virsh net-autostart zone2-ot