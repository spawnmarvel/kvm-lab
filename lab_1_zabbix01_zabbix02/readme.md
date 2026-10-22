# Online and offline vms

## Table of content

- [install-vms)](#install-vms)
- [architecture--network-flow)](#architecture--network-flow)
- [install-zabbix-mysql-and-proxy](#install-zabbix-mysql-and-proxy)



## install vms

```bash

cd script_kvm

bash create-ubuntu.zabbix02.sh

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
## install zabbix, mysql and proxy


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



