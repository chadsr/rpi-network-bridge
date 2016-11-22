#!/bin/bash

function get_address() {
  addr=$(ifconfig $1 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
  echo "$addr"
}

function print_timestamp() {
  date "+%s"
}

echo "This script needs to be run with root priveledges (sudo $0)"
echo

echo "Enter the network interface which has Internet connection to forward. (e.g. wlan0): "
read inet_iface
echo

echo "Enter the local network interface you wish to forward to. (e.g. eth0): "
read local_iface
echo

inet_addr=$(get_address $inet_iface)
local_addr=$(get_address $local_iface)

echo
echo "Internet address is: "$inet_addr
echo "Local address is: "$local_addr
echo "If the above addresses look incorrect, something is wrong witht the interfaces you specified above. (or ifconfig is broken)"
echo

# Lease time for IP addresses
echo "Enter a IP lease time for the DHCP server (e.g. 12h): "
read dhcp_lease_time

# trim the last octave of the local ip for example ranges
base_ip=`echo $local_addr | cut -d"." -f1-3`

echo "Enter a starting IP for the DHCP server to assign from. (e.g. $base_ip.50): "
read start_ip
echo "Enter a end IP for the DHCP server to assign to. (e.g. $base_ip.150): "
read end_ip

DNSMASQ_CONF="
interface=$local_iface
listen-address=$local_addr # Listen on local (non internet address)
bind-interfaces      # Bind to the interface to make sure we arent sending things elsewhere
server=8.8.8.8       # Forward DNS requests to Google DNS
domain-needed        # Dont forward short names
bogus-priv           # Never forward addresses in the non-routed address spaces.
dhcp-range=$start_ip,$end_ip,$dhcp_lease_time
"

# make a backup of the previous dnsmasq.conf
echo "sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old."print_timestamp
echo "Created backup of dnsmasq.conf"

# Write the newly generated config to the file
echo "$DNSMASQ_CONF" | sudo tee /etc/dnsmasq.conf > /dev/null
echo "New dnsmasq.conf written to /etc/dnsmasq.conf"

# Uncomment net.ipv4.ip_forward=1, if commented out
sudo sed -i '/^#.* net.ipv4.ip_forward=1 /s/^#//' /etc/sysctl.conf
echo "Uncommented net.ipv4.ip_forward=1 in /etc/sysctl.conf (If it wasn't already)"

# iptables
echo "Generating iptables"
sudo iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE

# Persistence
echo 'iptables-save' | sudo tee /etc/iptables.ipv4.nat > /dev/null

# Create hook
echo 'iptables-restore < /etc/iptables.ipv4.nat' | sudo tee /lib/dhcpcd/dhcpcd-hooks/70-ipv4-nat > /dev/null
