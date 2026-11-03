# 03.11.2026

espenk@kvm-host:~$ sudo iptables -L FORWARD -v -n --line-numbers
[sudo: authenticate] Password:
Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1     5450 4379K LIBVIRT_FWX  all  --  *      *       0.0.0.0/0            0.0.0.0/0
2     5450 4379K LIBVIRT_FWI  all  --  *      *       0.0.0.0/0            0.0.0.0/0
3     2518  307K LIBVIRT_FWO  all  --  *      *       0.0.0.0/0            0.0.0.0/0
4        0     0 ACCEPT     all  --  virbr25 virbr20  0.0.0.0/0            0.0.0.0/0
5        0     0 ACCEPT     all  --  virbr20 virbr25  0.0.0.0/0            0.0.0.0/0
6        0     0 ACCEPT     all  --  *      *       10.68.20.0/24        10.68.68.0/24
7        0     0 ACCEPT     all  --  *      *       10.68.68.0/24        10.68.20.0/24
8        0     0 ACCEPT     all  --  virbr20 virbr25  0.0.0.0/0            0.0.0.0/0
9        0     0 ACCEPT     all  --  virbr25 virbr20  0.0.0.0/0            0.0.0.0/0
10       0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
11       0     0 ACCEPT     tcp  --  *      eno1    10.68.68.10          0.0.0.0/0            multiport dports 80,443
12       0     0 ACCEPT     tcp  --  *      *       10.68.68.10          10.68.68.0/24        tcp dpt:22
13       0     0 ACCEPT     tcp  --  *      *       10.68.68.10          10.68.20.0/24        tcp dpt:22
14       0     0 ACCEPT     tcp  --  *      *       10.68.68.0/24        10.68.68.10          tcp dpt:3142
15       0     0 ACCEPT     tcp  --  *      *       10.68.20.0/24        10.68.68.10          tcp dpt:3142
16       0     0 ACCEPT     tcp  --  *      *       10.68.20.0/24        10.68.68.10          tcp dpt:80
17       0     0 ACCEPT     tcp  --  *      *       10.68.68.50          10.68.68.52          tcp dpt:3306
18       0     0 ACCEPT     tcp  --  *      *       10.68.20.15          10.68.68.50          tcp dpt:10051
19       0     0 DROP       all  --  *      eno1    10.68.68.0/24        0.0.0.0/0
20       0     0 DROP       all  --  *      eno1    10.68.20.0/24        0.0.0.0/0
21       0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
22       0     0 ACCEPT     tcp  --  *      *       10.68.68.10          0.0.0.0/0            multiport dports 80,443
23       0     0 ACCEPT     tcp  --  *      *       10.68.68.10          10.68.68.0/24        tcp dpt:22
24       0     0 ACCEPT     tcp  --  *      *       10.68.68.10          10.68.20.0/24        tcp dpt:22
25       0     0 ACCEPT     tcp  --  *      *       10.68.68.0/24        10.68.68.10          tcp dpt:3142
26       0     0 ACCEPT     tcp  --  *      *       10.68.20.0/24        10.68.68.10          tcp dpt:3142
27       0     0 ACCEPT     tcp  --  *      *       10.68.20.0/24        10.68.68.10          tcp dpt:80
28       0     0 ACCEPT     tcp  --  *      *       10.68.68.50          10.68.68.52          tcp dpt:3306
29       0     0 ACCEPT     tcp  --  *      *       10.68.20.15          10.68.68.50          tcp dpt:10051

# clean it up and remove the duplicates
cd /etc/iptables/
ls
rules.v4  rules.v6
sudo cp rules.v4 rules.v4_bck

sudo nano /etc/iptables/rules.v4

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:LIBVIRT_FWI - [0:0]
:LIBVIRT_FWO - [0:0]
:LIBVIRT_FWX - [0:0]
:LIBVIRT_INP - [0:0]
:LIBVIRT_OUT - [0:0]
:LIBVIRT_PRT - [0:0]

# Libvirt default chain hooks
-A FORWARD -j LIBVIRT_FWX
-A FORWARD -j LIBVIRT_FWI
-A FORWARD -j LIBVIRT_FWO

# Authoritative inter-bridge routing between Zone 25 iDMZ (virbr25) and Zone 2 OT (virbr20)
-A FORWARD -i virbr25 -o virbr20 -j ACCEPT
-A FORWARD -i virbr20 -o virbr25 -j ACCEPT

# Established connections
-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Specific Service & Management Rules
-A FORWARD -p tcp --dport 3142 -s 10.68.20.0/24 -d 10.68.68.10 -j ACCEPT
-A FORWARD -p tcp --dport 3142 -s 10.68.68.0/24 -d 10.68.68.10 -j ACCEPT
-A FORWARD -p tcp --dport 3306 -s 10.68.68.50 -d 10.68.68.52 -j ACCEPT
-A FORWARD -p tcp --dport 10051 -s 10.68.20.15 -d 10.68.68.50 -j ACCEPT

COMMIT


sudo netfilter-persistent reload
run-parts: executing /usr/share/netfilter-persistent/plugins.d/15-ip4tables start
run-parts: executing /usr/share/netfilter-persistent/plugins.d/25-ip6tables start

sudo iptables -L FORWARD -v -n --line-numbers


sudo iptables -L FORWARD -v -n --line-numbers
Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1        0     0 LIBVIRT_FWX  all  --  *      *       0.0.0.0/0            0.0.0.0/0
2        0     0 LIBVIRT_FWI  all  --  *      *       0.0.0.0/0            0.0.0.0/0
3        0     0 LIBVIRT_FWO  all  --  *      *       0.0.0.0/0            0.0.0.0/0
4        0     0 ACCEPT     all  --  virbr25 virbr20  0.0.0.0/0            0.0.0.0/0
5        0     0 ACCEPT     all  --  virbr20 virbr25  0.0.0.0/0            0.0.0.0/0
6        0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
7        0     0 ACCEPT     tcp  --  *      *       10.68.20.0/24        10.68.68.10          tcp dpt:3142
8        0     0 ACCEPT     tcp  --  *      *       10.68.68.0/24        10.68.68.10          tcp dpt:3142
9        0     0 ACCEPT     tcp  --  *      *       10.68.68.50          10.68.68.52          tcp dpt:3306
10       0     0 ACCEPT     tcp  --  *      *       10.68.20.15          10.68.68.50          tcp dpt:10051

espenk@kvm-host:~$ ssh master@10.68.68.10

master@ansiblectr01:~/io_ot_lab$ ansible-playbook -i inventory/hosts.ini playbooks/ping_host.yml

PLAY [Verify Connectivity Across Purdue Lab Nodes] *********************************************************************

TASK [Ping all inventory hosts] ****************************************************************************************
[WARNING]: Host 'ansiblectr01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [ansiblectr01]
[WARNING]: Host 'mysql01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [mysql01]
[WARNING]: Host 'zabbix01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix01]
[WARNING]: Host 'zabbix02' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix02]

PLAY RECAP *************************************************************************************************************
ansiblectr01               : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
mysql01                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix01                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix02                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


master@ansiblectr01:~/io_ot_lab$ ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml

PLAY [Configure Internal APT Caching Proxy] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Host 'mysql01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [mysql01]
[WARNING]: Host 'zabbix02' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix02]
[WARNING]: Host 'zabbix01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix01]

TASK [Set APT Proxy configuration file] ********************************************************************************
ok: [mysql01]
ok: [zabbix02]
ok: [zabbix01]

PLAY RECAP *************************************************************************************************************
mysql01                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix01                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix02                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


# boot hosts and verify that apt-cacher-ng is working and pings are successful
espenk@kvm-host:~$ sudo shutdown -r now

ssh espenk@192.168.10.70

sudo virsh list
[sudo: authenticate] Password:
 Id   Name           State
------------------------------
 1    zabbix02       running
 2    zabbix01       running
 3    mysql01        running
 4    ansiblectr01   running

espenk@kvm-host:~$ ssh master@10.68.68.10
master@10.68.68.10's password:


espenk@kvm-host:~$ ssh master@10.68.68.50
master@10.68.68.50's password:

espenk@kvm-host:~$ ssh master@10.68.68.52
master@10.68.68.52's password:

espenk@kvm-host:~$ ssh master@10.68.20.15
master@10.68.20.15's password:

# seems fine, now let's test apt-cacher-ng by updating the apt cache on the hosts


master@ansiblectr01:~$ cd io_ot_lab/

master@ansiblectr01:~/io_ot_lab$ ansible-playbook -i inventory/hosts.ini playbooks/ping_host.yml

PLAY [Verify Connectivity Across Purdue Lab Nodes] *********************************************************************

TASK [Ping all inventory hosts] ****************************************************************************************
[WARNING]: Host 'ansiblectr01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [ansiblectr01]
[WARNING]: Host 'zabbix02' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix02]
[WARNING]: Host 'mysql01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [mysql01]
[WARNING]: Host 'zabbix01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix01]

PLAY RECAP *************************************************************************************************************
ansiblectr01               : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
mysql01                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix01                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix02                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

master@ansiblectr01:~/io_ot_lab$ ansible-playbook -i inventory/hosts.ini playbooks/configure_apt_proxy.yml

PLAY [Configure Internal APT Caching Proxy] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Host 'mysql01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [mysql01]
[WARNING]: Host 'zabbix02' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix02]
[WARNING]: Host 'zabbix01' is using the discovered Python interpreter at '/usr/bin/python3.14', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.21/reference_appendices/interpreter_discovery.html for more information.
ok: [zabbix01]

TASK [Set APT Proxy configuration file] ********************************************************************************
ok: [mysql01]
ok: [zabbix02]
ok: [zabbix01]

PLAY RECAP *************************************************************************************************************
mysql01                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix01                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
zabbix02                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0