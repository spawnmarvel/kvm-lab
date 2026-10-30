sudo ufw status verbose
# status inactive

nc -z -v -w 3  178.128.6.101 80

nc -z -v -w 3  178.128.6.101 443

# Connection refused: The packet made it to the destination server, 
# but a firewall on that server (like ufw or iptables) or the service itself rejected it.

# Connection timed out: The packet was dropped entirely. 
# This usually means a network firewall along the path (like a corporate firewall, cloud security group, or router) is silently ignoring your traffic.



# Before blaming the firewall, make sure your system actually knows how to reach that IP. Run a quick trace:
ip route get 178.128.6.101
# If it says Network is unreachable, your system doesn't 
# have a route to get there (e.g., your VPN is down or your gateway is misconfigured).


# Ubuntu comes with a built-in alternative called tracepath

sudo tracepath -n 178.128.6.101