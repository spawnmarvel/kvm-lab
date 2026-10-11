#!/usr/bin/env bash
# Version 1.0.0
# Layer 4 TCP connectivity tester for repository endpoints

DOMAINS=(
  "archive.ubuntu.com"
  "security.ubuntu.com"
  "repo.zabbix.com"
  "repo.mysql.com"
  "dev.mysql.com"
)

PORTS=(80 443)

for domain in "${DOMAINS[@]}"; do
  for port in "${PORTS[@]}"; do
    if nc -z -v -w 3 "$domain" "$port" >/dev/null 2>&1; filter_out=$?; [ $filter_out -eq 0 ]; then
      echo "L4 OK: $domain:$port"
    else
      echo "L4 FAIL: $domain:$port"
    fi
  done
done