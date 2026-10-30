#!/bin/bash
resolvectl status
resolvectl query archive.ubuntu.com
resolvectl query security.ubuntu.com
resolvectl query repo.zabbix.com
resolvectl query repo.mysql.com
resolvectl query dev.mysql.com

# To see all your active domains and find out if a link is snatching traffic with a ~. rule, ru
resolvectl domain