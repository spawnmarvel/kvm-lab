# Online and offline vms

## Table of content

- [Online and offline vms](#online-and-offline-vms)
- [install vms](#install-vms)
- [architecture \& network flow scenario 1 proxy offline](#architecture--network-flow-scenario-1-proxy-offline)
- [install zabbix, mysql already done](#install-zabbix-mysql-already-done)
- [install proxy](#install-proxy)
- [architecture \& network flow scenario 2 all offline](#architecture--network-flow-scenario-2-all-offline)



## install vms

```bash

cd scripts_kvm

# create the new vm

# we already have this
# bash create-ubuntu.zabbix01.sh

bash create-ubuntu.zabbix02_proxy.sh


```

## architecture & network flow scenario 1 proxy offline


In this setup, zabbix01 (10.68.68.50) acts as the internet-connected jump host and main Zabbix Server. 

zabbix02 (10.68.68.51) will operate as an offline Zabbix Proxy with strict firewall rules restricting outbound connections strictly to the Zabbix Server port (10051/tcp) and inbound connections to its agent port (10050/tcp)


```bash

ssh master@10.68.68.50

master@zabbix01:~$ cat /etc/os-release 
PRETTY_NAME="Ubuntu 26.04 LTS"

sudo apt update

sudo apt upgrade

# install mysql 8.4 is default, so install from apt

# install zabbix and configure it

# enable the kvm host in zabbix

ssh proxy@10.68.68.51

proxyman@zabbix02:~$ cat /etc/os-release 
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"





```
## install zabbix, mysql already done


We have already mysql and zabbix on zabbix01

```bash

ssh master@10.68.68.50

# install zabbix and configure it

# sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu26.04_all.deb

# sudo dpkg -i zabbix-release_latest_7.0+ubuntu26.04_all.deb 
```


Go to https://10.68.68.50/zabbix

![zabbix01](https://github.com/spawnmarvel/kvm-lab/blob/main/images/zabbix01.png)


## install proxy and allow verfify tcp out


Enable UFW and install proxy on zabbix02

```bash

# enable the kvm host in zabbix

ssh proxy@10.68.68.51

sudo ufw default deny outgoing

# They allow external hosts to connect to zabbix02

sudo ufw allow OpenSSH

sudo ufw allow 22

sudo ufw allow 10051

sudo ufw allow 10050

sudo ufw show added

sudo ufw enable 

# If UFW's default outgoing policy is set to deny or reject
#  (or if kernel connection tracking conntrack drops stateful response packets), 
# standard inbound ALLOW rules do not permit outbound traffic or return SYN-ACK packets

# Explicitly Allow Outbound Traffic
sudo ufw allow out to 10.68.68.50 port 10051 proto tcp

# Check UFW default incoming and outgoing policies
sudo ufw staus verbose

Status: active
Logging: on (low)
Default: deny (incoming), deny (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp (OpenSSH)           ALLOW IN    Anywhere                  
22                         ALLOW IN    Anywhere                  
10051                      ALLOW IN    Anywhere                  
10050                      ALLOW IN    Anywhere                  
22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)             
22 (v6)                    ALLOW IN    Anywhere (v6)             
10051 (v6)                 ALLOW IN    Anywhere (v6)             
10050 (v6)                 ALLOW IN    Anywhere (v6)             

10.68.68.50 10051/tcp      ALLOW OUT   Anywhere 

```

Take a snapshot


```bash

# create snap
sudo virsh snapshot-create-as  --domain ubuntu-zabbix02 --name "clean-install"

# list snaps
sudo virsh snapshot-list ubuntu-zabbix02 


``` 


Install proxy

```bash
# login to online machine, the zabbix server, where zabbix is installed
ssh master@10.68.68.50
# check what we have
ls
ls
server.crt  server.key  zabbix-release_latest_7.0+ubuntu26.04_all.deb

# Create staging directory
mkdir -p ~/zabbix_offline_proxy && cd ~/zabbix_offline_proxy

sudo apt update

# this is what we need
# https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=26.04&components=proxy&db=sqlite3&ws=


# Download required packages without installing
sudo apt-get download \
  zabbix-proxy-sqlite3 \
  zabbix-sql-scripts \
  sqlite3 \
  libsqlite3-0 \
  fping \
  libcares2 \
  libevent-extra-2.1-7t64 \
  libevent-pthreads-2.1-7t64 \
  libodbc2 \
  libopenipmi0t64 \
  libsnmp40t64 \
  libssh-4 \
  libltdl7 \
  libsnmp-base

# The .deb files were successfully downloaded to zabbix_offline_proxy. 
# The W: Download is performed unsandboxed message is harmless—it,
#  happens because apt-get download was executed as root inside the user's home directory (/home/master/).

# scp to move the files
scp -r ~/zabbix_offline_proxy proxyman@10.68.68.51:/tmp/

exit

# enter proxy server
ssh proxyman@10.68.68.51

# enter
cd /tmp/zabbix_offline_proxy/

ls

fping_5.1-1build1_amd64.deb
libcares2_1.34.6-1ubuntu0.2_amd64.deb
libevent-extra-2.1-7t64_2.1.12-stable-10ubuntu0.2_amd64.deb
libevent-pthreads-2.1-7t64_2.1.12-stable-10ubuntu0.2_amd64.deb
libltdl7_2.5.4-9_amd64.deb
libodbc2_2.3.14-1_amd64.deb
libopenipmi0t64_2.0.37-1build1_amd64.deb
libsnmp-base_5.9.4+dfsg-2ubuntu3_all.deb
libsnmp40t64_5.9.4+dfsg-2ubuntu3_amd64.deb
libsqlite3-0_3.46.1-9ubuntu0.3_amd64.deb
libssh-4_0.11.3-1ubuntu2.1_amd64.deb
sqlite3_3.46.1-9ubuntu0.3_amd64.deb
zabbix-proxy-sqlite3_1%3a7.0.32-2+ubuntu26.04_amd64.deb
zabbix-sql-scripts_1%3a7.0.32-2+ubuntu26.04_all.deb

# Install newly transferred dependencies and configure all packages
sudo dpkg -i *.deb

# check file
ls -lah /etc/zabbix

# Update configuration parameters in zabbix_proxy.conf (Active Proxy Mode)
sudo sed -i 's|^# ProxyMode=.*|ProxyMode=0|' /etc/zabbix/zabbix_proxy.conf
sudo sed -i 's|^ProxyMode=.*|ProxyMode=0|' /etc/zabbix/zabbix_proxy.conf
sudo sed -i 's|^Server=.*|Server=10.68.68.50|' /etc/zabbix/zabbix_proxy.conf
sudo sed -i 's|^Hostname=.*|Hostname=zabbix02|' /etc/zabbix/zabbix_proxy.conf
sudo sed -i 's|^DBName=.*|DBName=/var/lib/zabbix/zabbix_proxy.db|' /etc/zabbix/zabbix_proxy.conf

# Fix permissions on config files to allow zabbix user access
sudo chown -R zabbix:zabbix /etc/zabbix/
sudo chmod 750 /etc/zabbix/
sudo chmod 640 /etc/zabbix/zabbix_proxy.conf


# Create database directory and populate schema
sudo mkdir -p /var/lib/zabbix
sudo chown -R zabbix:zabbix /var/lib/zabbix
sudo chmod 750 /var/lib/zabbix

# Populate schema into SQLite database file
sudo -u zabbix sqlite3 /var/lib/zabbix/zabbix_proxy.db < /usr/share/zabbix-sql-scripts/sqlite3/proxy.sql

# Set proper ownership and permissions on the created DB file
sudo chown zabbix:zabbix /var/lib/zabbix/zabbix_proxy.db
sudo chmod 640 /var/lib/zabbix/zabbix_proxy.db

# Enable and start zabbix-proxy
sudo systemctl enable zabbix-proxy
sudo systemctl restart zabbix-proxy

# Verify service logs
sudo tail -n 20 /var/log/zabbix/zabbix_proxy.log

``` 

Now go to zabbix server and enable proxy

Hm, it gets state offline

```bash
master@zabbix01:~$ ip a

# inet 10.68.68.50/24
# 2: enp1s0:

master@zabbix01:~$ ip route

# default via 10.68.68.1


proxyman@zabbix02:~$ ip a

# inet 10.68.68.51/24
# 2: enp1s0:

proxyman@zabbix02:~$ ip route

# default via 10.68.68.1

```

Both VMs are on the same subnet (10.68.68.0/24) using the same interface (enp1s0) and default gateway (10.68.68.1).

Since zabbix01 has no active UFW firewall, the total failure of ICMP (ping) and TCP (nc) between 10.68.68.50 and 10.68.68.51 points directly to:

### Step 1: Check ARP Cache & Layer 2 MAC Discovery

Run an ARP lookup on zabbix02 while pinging zabbix01

```bash

# Log in to zabbix02 (10.68.68.51
ping -c 2 10.68.68.50
ip neighbor show | grep 10.68.68.50


```

Log

```txt
ping -c 2 10.68.68.50
ip neighbor show | grep 10.68.68.50
PING 10.68.68.50 (10.68.68.50) 56(84) bytes of data.

--- 10.68.68.50 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1008ms

10.68.68.50 dev enp1s0 lladdr 52:54:00:11:22:33 STALE 

``` 

The ARP lookup output (52:54:00:11:22:33 STALE) confirms that Layer 2 Ethernet connectivity does exist between the virtual NICs—zabbix02 successfully resolved the exact MAC address of zabbix01 (52:54:00:11:22:33).


### Step 2: Step 1: Test Disabling UFW on zabbix02

Run these commands on zabbix02 to temporarily disable UFW and test if local rules are dropping inbound ICMP replies:

```bash
sudo ufw disable
ping -c 2 10.68.68.50
nc -zv -w 3 10.68.68.50 10051
```

Log

```txt
sudo ufw disable
ping -c 2 10.68.68.50
nc -zv -w 3 10.68.68.50 10051
Firewall stopped and disabled on system startup
PING 10.68.68.50 (10.68.68.50) 56(84) bytes of data.
64 bytes from 10.68.68.50: icmp_seq=1 ttl=64 time=0.255 ms
64 bytes from 10.68.68.50: icmp_seq=2 ttl=64 time=0.536 ms

--- 10.68.68.50 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1024ms
rtt min/avg/max/mdev = 0.255/0.395/0.536/0.140 ms
Connection to 10.68.68.50 10051 port [tcp/zabbix-trapper] succeeded!
``` 

The root cause was UFW on zabbix02 dropping returning packets or blocking outbound traffic to 10.68.68.50

Check ufw before

```bash
sudo ufw enable

sudo ufw status 
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere                  
22                         ALLOW       Anywhere                  
10051                      ALLOW       Anywhere                  
10050                      ALLOW       Anywhere                  
OpenSSH (v6)               ALLOW       Anywhere (v6)             
22 (v6)                    ALLOW       Anywhere (v6)             
10051 (v6)                 ALLOW       Anywhere (v6)             
10050 (v6)                 ALLOW       Anywhere (v6)

```

Explicitly Allow Outbound Traffic

```bash
# Explicitly Allow Outbound Traffic
sudo ufw allow out to 10.68.68.50 port 10051 proto tcp

# Run ufw status verbose on zabbix02 to view the active default policies for incoming, outgoing, and routed traffic
sudo ufw status verbose

Status: active
Logging: on (low)
Default: deny (incoming), deny (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp (OpenSSH)           ALLOW IN    Anywhere                  
22                         ALLOW IN    Anywhere                  
10051                      ALLOW IN    Anywhere                  
10050                      ALLOW IN    Anywhere                  
22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)             
22 (v6)                    ALLOW IN    Anywhere (v6)             
10051 (v6)                 ALLOW IN    Anywhere (v6)             
10050 (v6)                 ALLOW IN    Anywhere (v6)             

10.68.68.50 10051/tcp      ALLOW OUT   Anywhere 
``` 

And we he have the proxy data in zabbix


Go to https://10.68.68.50/zabbix

![zabbix02 proxy](https://github.com/spawnmarvel/kvm-lab/blob/main/images/zabbix02_proxy.png)


## architecture & network flow scenario 2 all offline


