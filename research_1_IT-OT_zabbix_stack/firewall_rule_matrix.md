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


1. Executive Summary & Security Standard Alignment

This security defense proposal outlines the architectural justification for the Day-2 Zabbix monitoring and Ansible configuration management stack deployed across Zone 2.5 (iDMZ) and Zone 2 (Control/OT).

The proposed firewall architecture enforces Zero-Trust boundary defense and aligns directly with key industrial cybersecurity standards:

* IEC 62443-3-3 / ISA-95: Strict Zone and Conduit segmentation separating industrial operations from enterprise networks and external entities.

* NIST SP 800-82 Rev. 3 (Guide to OT Security): Implementation of an iDMZ barrier to prevent direct communication between lower OT control zones and higher-level networks or public endpoints.

* CIS Controls v8: Strict inventory control, software update management, and defensive network configuration.


```txt
┌──────────────────────────────────────────┐
                  │ External / Internet (Explicit FQDNs)     │
                  └────────────────────▲─────────────────────┘
                                       │
                                       │ Outbound HTTPS/HTTP (TCP 443/80)
                                       │ Explicit FQDN Whitelist ONLY
┌──────────────────────────────────────┴──────────────────────────────────┐
│ Zone 2.5 (iDMZ)                                                         │
│  ├── [ ansiblectr01 ] ── Single Outbound Egress & Internal APT Cacher   │
│  ├── [ zabbix01 ]     ── Zabbix Server & Web Interface                  │
│  └── [ mysql01 ]      ── MySQL 8.4 LTS (Isolated Data Drive)            │
└──────────────────────────────────────▲──────────────────────────────────┘
                                       │
                                       │ Stateful Outbound Push (TCP 10051)
                                       │ NO Inbound Connections into Zone 2
┌──────────────────────────────────────┴──────────────────────────────────┐
│ Zone 2 (Control / OT Network)                                           │
│  ├── [ zabbix02 ]     ── Zabbix Active Proxy (SQLite3)                  │
│  └── [ Windows VMs ]  ── Monitored Endpoints (Read-Only Metrics)        │
└─────────────────────────────────────────────────────────────────────────┘
```