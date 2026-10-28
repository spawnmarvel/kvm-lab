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


sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw allow OpenSSH
sudo ufw allow 22
sudo ufw allow 10051
sudo ufw allow 10050
sudo ufw show added
sudo ufw enable



```
## install zabbix, mysql already done


We have already mysql and zabbix on zabbix01

```bash

ssh master@10.68.68.50

# install zabbix and configure it

# sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu26.04_all.deb

# sudo dpkg -i zabbix-release_latest_7.0+ubuntu26.04_all.deb 
``


Go to https://10.68.68.50/zabbix

![zabbix01](https://github.com/spawnmarvel/kvm-lab/blob/main/images/zabbix01.png)


## install proxy


Enable UFW and install proxy on zabbix02

```bash

# enable the kvm host in zabbix

ssh proxy@10.68.68.51

sudo ufw default deny outgoing

sudo ufw allow OpenSSH

sudo ufw allow 22

sudo ufw allow 10051

sudo ufw allow 10050

sudo ufw show added

sudo ufw enable 


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

``


## architecture & network flow scenario 2 all offline


