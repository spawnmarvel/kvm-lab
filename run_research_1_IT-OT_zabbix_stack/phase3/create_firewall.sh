#!/bin/bash
# Version: 1.0.1
# Description: Enforces single-egress internet blocking on libvirt bridge networks by inserting drop rules ahead of libvirt defaults

set -euo pipefail

# Dynamically identify default internet interface
EXT_IF=$(ip route show default | awk '{print $5}' | head -n1)

ANSIBLE_IP="10.68.68.10"
ZABBIX_SERVER_IP="10.68.68.50"
MYSQL_IP="10.68.68.52"
OT_PROXY_IP="10.68.20.15"

IDMZ_SUBNET="10.68.68.0/24"
OT_SUBNET="10.68.20.0/24"

echo "Applying strict single-egress rules on external interface: ${EXT_IF}"

# 1. Allow established and related connections first
sudo iptables -I FORWARD 1 -m state --state ESTABLISHED,RELATED -j ACCEPT

# 2. Allow outbound internet traffic ONLY for ansiblectr01 (10.68.68.10)
sudo iptables -I FORWARD 2 -s ${ANSIBLE_IP} -o ${EXT_IF} -p tcp -m multiport --dports 80,443 -j ACCEPT

# 3. Allow internal SSH management from ansiblectr01
sudo iptables -I FORWARD 3 -s ${ANSIBLE_IP} -d ${IDMZ_SUBNET} -p tcp --dport 22 -j ACCEPT
sudo iptables -I FORWARD 4 -s ${ANSIBLE_IP} -d ${OT_SUBNET} -p tcp --dport 22 -j ACCEPT

# 4. Allow internal APT proxy (3142) and HTTP (80) traffic to ansiblectr01
sudo iptables -I FORWARD 5 -s ${IDMZ_SUBNET} -d ${ANSIBLE_IP} -p tcp --dport 3142 -j ACCEPT
sudo iptables -I FORWARD 6 -s ${OT_SUBNET} -d ${ANSIBLE_IP} -p tcp --dport 3142 -j ACCEPT
sudo iptables -I FORWARD 7 -s ${OT_SUBNET} -d ${ANSIBLE_IP} -p tcp --dport 80 -j ACCEPT

# 5. Allow MySQL (3306) and Zabbix Active Proxy (10051)
sudo iptables -I FORWARD 8 -s ${ZABBIX_SERVER_IP} -d ${MYSQL_IP} -p tcp --dport 3306 -j ACCEPT
sudo iptables -I FORWARD 9 -s ${OT_PROXY_IP} -d ${ZABBIX_SERVER_IP} -p tcp --dport 10051 -j ACCEPT

# 6. BLOCK all other direct internet egress from iDMZ and OT subnets out external interface
sudo iptables -I FORWARD 10 -s ${IDMZ_SUBNET} -o ${EXT_IF} -j DROP
sudo iptables -I FORWARD 11 -s ${OT_SUBNET} -o ${EXT_IF} -j DROP

# Save updated rules persistently
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null

echo "Firewall rules updated and persisted."