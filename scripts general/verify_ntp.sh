#!/bin/bash
GATEWAY_IP=$(ip route | grep default | awk '{print $3}') 
echo "Testing Gateway IP: $GATEWAY_IP" 
nc -z -v -u $GATEWAY_IP 123
