# Firewall Rule Matrix (Purdue / ISA-95 Architecture)

| Rule ID | Source Host | Source Zone | Destination FQDN / Host | Destination Zone | Protocol / Port | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **FW-01a** | `ansiblectr01` | Zone 2.5 (iDMZ) | `archive.ubuntu.com`, `security.ubuntu.com` | External / Internet | TCP 80, 443 | Ubuntu OS repository update traffic |
| **FW-01b** | `ansiblectr01` | Zone 2.5 (iDMZ) | `repo.zabbix.com`, `cdn.zabbix.com` | External / Internet | TCP 80, 443 | Zabbix APT repository & Agent2 `.msi` downloads |
| **FW-01c** | `ansiblectr01` | Zone 2.5 (iDMZ) | `ppa.launchpadcontent.net`, `galaxy.ansible.com` | External / Internet | TCP 80, 443 | Ansible PPA repository & Ansible Galaxy collections |
| **FW-02** | `ansiblectr01` | Zone 2.5 (iDMZ) | `zabbix01`, `mysql01` | Zone 2.5 (iDMZ) | TCP 22 | Ansible SSH configuration & management |
| **FW-03** | `ansiblectr01` | Zone 2.5 (iDMZ) | `zabbix02` | Zone 2 (Control/OT) | TCP 22 | Ansible SSH configuration & management |
| **FW-04** | `ansiblectr01` | Zone 2.5 (iDMZ) | Windows VMs | Zone 2 (Control/OT) | TCP 5985, 5986 or 22 | Ansible WinRM / SSH management |
| **FW-05** | `zabbix01`, `mysql01` | Zone 2.5 (iDMZ) | `ansiblectr01` | Zone 2.5 (iDMZ) | TCP 3142 | Internal APT package updates (`apt-cacher-ng`) |
| **FW-06** | `zabbix02` | Zone 2 (Control/OT) | `ansiblectr01` | Zone 2.5 (iDMZ) | TCP 3142 | Internal APT package updates (`apt-cacher-ng`) |
| **FW-07** | Windows VMs | Zone 2 (Control/OT) | `ansiblectr01` | Zone 2.5 (iDMZ) | TCP 80 | Apache HTTP download of `zabbix_agent2.msi` |
| **FW-08** | `zabbix01` | Zone 2.5 (iDMZ) | `mysql01` | Zone 2.5 (iDMZ) | TCP 3306 | MySQL database query traffic |
| **FW-09** | `zabbix02` | Zone 2 (Control/OT) | `zabbix01` | Zone 2.5 (iDMZ) | TCP 10051 | Active Proxy metric data push |
| **FW-10** | Windows VMs | Zone 2 (Control/OT) | `zabbix02` | Zone 2 (Control/OT) | TCP 10051 | Zabbix Agent2 active metric submission |
| **FW-11** | Admin Workstations | Level 3.5 (IT) | `zabbix01` | Zone 2.5 (iDMZ) | TCP 80, 443 | Zabbix Web Frontend user interface access |