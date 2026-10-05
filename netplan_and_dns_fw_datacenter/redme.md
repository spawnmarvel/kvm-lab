# Quick Checklist for Repository Connectivity


## Table of contents

- [Quick Checklist for Repository Connectivity](#quick-checklist-for-repository-connectivity)
  - [Table of contents](#table-of-contents)
  - [Scenario, offline vms that needs direct access to some repsitories.](#scenario-offline-vms-that-needs-direct-access-to-some-repsitories)
  - [Prerequisites: Global \& Interface DNS Setup check](#prerequisites-global--interface-dns-setup-check)
  - [1. Verify DNS Lookup (Port 53) and test routing and firwall rules](#1-verify-dns-lookup-port-53-and-test-routing-and-firwall-rules)
  - [Why Editing Netplan Is Still Highly Recommended after test FW](#why-editing-netplan-is-still-highly-recommended-after-test-fw)
- [More troubleshooting if 1 does not work](#more-troubleshooting-if-1-does-not-work)
  - [2. Check Default Gateway (Routing)](#2-check-default-gateway-routing)
  - [3. Test Firewall Connectivity (Port 80/443)](#3-test-firewall-connectivity-port-80443)
  - [4. Force IPv4 in APT (In Case of IPv6 Conflicts) optional](#4-force-ipv4-in-apt-in-case-of-ipv6-conflicts-optional)
  - [Appendix: Why Netplan Hardening is Recommended](#appendix-why-netplan-hardening-is-recommended)

## Scenario, offline vms that needs direct access to some repsitories.

* Firewall rules for HTTP/HTTPS outbound access on TCP ports 80 and 443

* archive.ubuntu.com / security.ubuntu.com (Ubuntu OS updates)

* repo.zabbix.com (Zabbix packages & keys)

* repo.mysql.com / dev.mysql.com (MySQL 8.4 LTS packages & configuration DEB files)


Use this checklist in order to isolate the root cause in under 2 minutes:


## Prerequisites: Global & Interface DNS Setup check


Yes, updating your DNS configuration is the essential Prerequisite Step before running any connectivity tests. Without a working DNS server, your system cannot resolve domain names to IP addresses.

Configure Global DNS: Set your primary DNS server in /etc/systemd/resolved.conf

```ini
[Resolve]
DNS=10.10.10.10

```

```bash

sudo systemctl restart systemd-resolved
```

Wait a bit with netplan.

Netplan Hardening: Once the firewall team confirms the ports are open and sudo apt update succeeds, applying the Netplan update ensures that your Ubuntu nodes will retain their DNS configuration through future maintenance reboots.

Override Interface DNS (If using DHCP): If your network card (ens33) receives an outdated DNS server via DHCP, override it in your Netplan configuration file

 (e.g., /etc/netplan/50-cloud-init.yaml):

```yml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
      nameservers:
        addresses:
          - 10.10.10.10

```

Apply the changes

```bash
sudo netplan apply
```
Restart the local resolver service and clear old DNS cache entries:

```bash

sudo systemctl restart systemd-resolved
sudo resolvectl flush-caches
```

Verify Active DNS Server:

```bash
resolvectl status
```

Verification: Ensure Current DNS Server shows 10.10.10.10 under both the Global section and your active link (ens33).


## 1. Verify DNS Lookup (Port 53) and test routing and firwall rules

```bash

resolvectl query archive.ubuntu.com
```

* OK: Returns IPv4 addresses.
* Error: Connection timed out The DNS server or UDP/TCP port 53 is blocked by the firewall.


```log
archive.ubuntu.com: 2620:2d:4002:1::102        -- link: ens33
                    2620:2d:4002:1::101        -- link: ens33
                    2a06:bc80:0:1000::17       -- link: ens33
                    [...]
                    91.189.92.24               -- link: ens33
                    185.125.190.81             -- link: ens33
                    91.189.92.23               -- link: ens33
```

IP Address Updates: Canonical's CDN IP addresses (91.189.91.81, 185.125.190.81, etc.) change dynamically across regions, so resolvectl query archive.ubuntu.com will always give you the exact IP needed for testing nc or curl

Yes, testing a direct connection to one of the resolved IP addresses is an excellent way to verify network routing and firewall rules.

Because resolvectl query archive.ubuntu.com returned IP addresses, your system's DNS lookup is working. Testing the resolved IP address directly bypasses DNS entirely and tests whether outbound traffic on TCP ports 80 and 443 is permitted through your datacenter firewall to Canonical's servers.

```bash
# Test Direct Connection via IP (Port 80 and 443)
nc -zv -w3 91.189.91.81 80
# Success Output: Connection to 91.189.91.81 443 port [tcp/https] succeeded!

# Test Direct HTTP Request via Curl
curl -I -m 5 --header "Host: archive.ubuntu.com" http://91.189.91.81/ubuntu/
# curl -I -m 5 --header "Host: archive.ubuntu.com" http://91.189.91.81/ubuntu/
```

Why This Proves It Is a Firewall / Routing Issue


When you test directly against an IP address (91.189.91.81):

1. DNS is completely bypassed: The test no longer relies on domain name lookups.
2. Pure Layer 4 (TCP) test: nc -zv attempts a basic TCP three-way handshake (SYN, SYN-ACK, ACK).
3. If nc fails: The SYN packet is either dropped silently by a firewall rule or blocked by a upstream router/gateway that lacks an outbound rule for ports 80/443 to that specific destination IP range.



## Why Editing Netplan Is Still Highly Recommended after test FW

About Netplan

* https://ubuntu.com/server/docs/explanation/networking/about-netplan/


While you are 100% correct that the immediate failure is caused by the firewall (since DNS resolution works, but Layer 4 TCP traffic fails), you still need to edit Netplan for your DNS setup to be reliable long-term.


Here is why:

1. Reboot Persistence: Editing /etc/systemd/resolved.conf sets the global fallback DNS, but if your interface (ens33) uses DHCP, the system will re-acquire the old/broken DNS server from the DHCP server every time the system reboots or the network interface restarts.
2. DNS Query Priority: systemd-resolved prioritizes interface-specific DNS servers (under Link 2 (ens33)) over global DNS settings ([Resolve]). If the DHCP server pushes an invalid DNS server to ens33, system queries can start failing again or timing out intermittently.

Netplan Configuration (Recommended Hardening): Once the firewall ticket is logged, spend 1 minute updating Netplan so that your DNS configuration survives future reboots or network re-initializations without issues.

Yes, exactly. You do not need to reboot or edit Netplan right now to test the firewall rule.

Since resolvectl query is already successfully returning IP addresses using your current DNS setup, you can test and verify the firewall rule immediately once the network team opens outbound access on ports 80 and 443. Updating Netplan can be done right after as a cleanup step to ensure the configuration remains persistent across future reboots.


You do not need to touch Netplan right now to test 

```bash
sudo apt update
```
Since resolvectl query is already successfully returning IP addresses for archive.ubuntu.com, systemd-resolved is actively translating domain names for your system in this current session. As soon as the firewall team opens outbound TCP access on ports 80 and 443, sudo apt update will work immediately without any Netplan modifications.

Netplan Hardening: Once the firewall team confirms the ports are open and sudo apt update succeeds, applying the Netplan update ensures that your Ubuntu nodes will retain their DNS configuration through future maintenance reboots.

# More troubleshooting if 1 does not work

## 2. Check Default Gateway (Routing)

```bash
ip route show | grep default
```

* OK: Outputs default via <IP> dev ens33.
* Error: No output The network interface is missing a default gateway in Netplan.

## 3. Test Firewall Connectivity (Port 80/443)

```bash
nc -zv -w3 archive.ubuntu.com 80
nc -zv -w3 archive.ubuntu.com 443
```

* OK: Connection to archive.ubuntu.com 80 port [tcp/http] succeeded!
* Error: Network is unreachable or Timed out The firewall is blocking the specific CDN IP address (ask the network team to allow the FQDN or Canonical IP ranges 91.189.88.0/21 and 185.125.188.0/22).

## 4. Force IPv4 in APT (In Case of IPv6 Conflicts) optional

If DNS returns IPv6 addresses that the firewall does not route:

```bash
echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
sudo apt update
```



## Appendix: Why Netplan Hardening is Recommended

While temporary fixes in /etc/systemd/resolved.conf allow immediate firewall testing during an active session, updating Netplan ensures long-term stability:


1. Reboot Persistence: /etc/systemd/resolved.conf acts as a global fallback. If ens33 uses DHCP, the interface re-acquires the old DNS server upon reboot or interface restart.

2. Query Priority: systemd-resolved prioritizes interface-specific DNS servers (Link ens33) over global settings ([Resolve]). Hardening Netplan prevents DHCP from overriding your local DNS configuration.