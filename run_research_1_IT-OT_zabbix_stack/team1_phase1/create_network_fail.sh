#!/bin/bash
# Version: 1.0.0
# Description: Defines, starts, and enables autostart for zone25-idmz and zone2-ot libvirt networks

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
  <bridge name='virbr20' state='unknown'/>
  <ip address='10.68.20.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.68.20.100' end='10.68.20.200'/>
    </dhcp>
  </ip>
</network>
EOF

sudo virsh net-define zone25-idmz.xml
sudo virsh net-start zone25-idmz
sudo virsh net-autostart zone25-idmz

sudo virsh net-define zone2-ot.xml
sudo virsh net-start zone2-ot
sudo virsh net-autostart zone2-ot