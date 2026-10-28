# Install Zabbix online

## Table of content

- [create vm](#create-vm)
- [install zabbix mysql](#install-zabbix-mysql)

## create vm

We done this many times

1. Install MySQL
2. Install Zabbix


```bash

cd scripts_kvm

# create the vm

bash create-ubuntu.zabbix01.sh
``` 

## install zabbix, mysql


Install mysql and zabbix on zabbix01.

The best thing to do is to separate them, but this is for test.

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

o to http://10.68.68.50/zabbix

*  set date to UTC

Update with a self signed certificate for Apache, yes.


Go to https://10.68.68.50/zabbix

Add som hosts

![zabbix01](https://github.com/spawnmarvel/kvm-lab/blob/main/images/zabbix01.png)


## Mysql no such database?


```bash

sudo killall -9 mysqld 2>/dev/null

sudo systemctl status mysql

``

