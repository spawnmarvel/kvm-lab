#!/usr/bin/env bash
# Version 1.0.0
# Layer 7 HTTP/HTTPS endpoint response tester for repository endpoints

DOMAINS=(
  "archive.ubuntu.com"
  "security.ubuntu.com"
  "repo.zabbix.com"
  "repo.mysql.com"
  "dev.mysql.com"
)

PROTOCOLS=("http" "https")

for domain in "${DOMAINS[@]}"; do
  for proto in "${PROTOCOLS[@]}"; do
    url="${proto}://${domain}"
    status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "$url")
    if [ "$status" -ne 000 ]; then
      echo "L7 OK ($status): $url"
    else
      echo "L7 FAIL (No Response/TLS Error): $url"
    fi
  done
done