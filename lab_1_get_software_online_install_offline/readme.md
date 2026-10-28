# Online and offline vms

## Table of content

- [Online and offline vms](#online-and-offline-vms)
  - [Table of content](#table-of-content)
  - [install vms](#install-vms)
  - [architecture \& network flow](#architecture--network-flow)
  - [install zabbix, mysql](#install-zabbix-mysql)
  - [install proxy](#install-proxy)
- [create snap](#create-snap)
- [list snaps](#list-snaps)



## install vms

```bash

cd scripts_kvm

# create the two vms

bash create-ubuntu.zabbix01.sh

bash create-ubuntu.zabbix02.sh


```

## architecture & network flow


In this setup, zabbix01 (10.68.68.50) acts as the internet-connected jump host and main Zabbix Server. zabbix02 (10.68.68.51) will operate as an offline Zabbix Proxy with strict firewall rules restricting outbound connections strictly to the Zabbix Server port (10051/tcp) and inbound connections to its agent port (10050/tcp)


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
## install zabbix, mysql


Install mysql and zabbix on zabbix01

```bash

ssh master@10.68.68.50

master@zabbix01:~$ cat /etc/os-release 
PRETTY_NAME="Ubuntu 26.04 LTS"

sudo apt update

sudo apt upgrade

# install mysql 8.4 is default, so install from apt
apt-cache policy mysql-server

sudo apt install mysql-server

sudo systemctl status mysql.service

sudo mysql_secure_installation

mysql --version
# mysql  Ver 8.4.11-0ubuntu0.26.04.1 for Linux on x86_64 ((Ubuntu))


sudo mysql

# install zabbix and configure it

sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu26.04_all.deb

sudo dpkg -i zabbix-release_latest_7.0+ubuntu26.04_all.deb 

sudo apt update

sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2

```

Create database

```sql
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user 'zabbix'@'%' identified by 'seedit123456';
grant all privileges on zabbix.* to 'zabbix'@'%';
set global log_bin_trust_function_creators = 1;
quit; 
```

Configure zabbix and create tables

```bash
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix 

sudo mysql
```

Stop database log

```sql
set global log_bin_trust_function_creators = 0;
quit; 
```

Edit config

* DBPassword=seedit123456

```bash
sudo systemctl restart zabbix-server zabbix-agent2 apache2 php8.5-fpm

# The error Invalid command 'ProxyTimeout' occurs because Apache's mod_proxy module is not enabled.
journalctl -xeu apache2.service

sudo a2enmod proxy proxy_fcgi
sudo apachectl configtest
sudo systemctl restart apache2
sudo systemctl status apache2

sudo systemctl restart zabbix-server zabbix-agent2 apache2 php8.5-fpm

sudo systemctl enable zabbix-server zabbix-agent2 apache2 php8.5-fpm

# get the date to use in zabbix
date
Thu Oct 22 06:18:57 PM UTC 2026
```

Go to http://10.68.68.50/zabbix

*  set date to UTC

Update with a self signed certificate for Apache, yes.


Go to https://10.68.68.50/zabbix


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


``



