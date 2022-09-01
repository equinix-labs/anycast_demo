#!/bin/bash

echo "$(date)" >> /root/timer
until [ $(curl -s https://metadata.platformequinix.com/metadata | jq -r '.bgp_neighbors[0].peer_ips[0]') != 'null' ]; do
  echo "$(date)" >> /root/timer
  sleep 10
done

json=$(curl -s https://metadata.platformequinix.com/metadata)
MY_PRIVATE_IP=$(echo $json | jq -r ".network.addresses[] | select(.public == false) | .address")
MY_PRIVATE_GW=$(echo $json | jq -r '.network.addresses[] | select(.public == true and .address_family == 4).gateway')
MY_PEER_1=$(echo $json | jq -r '.bgp_neighbors[0].peer_ips[0]')
MY_PEER_2=$(echo $json | jq -r '.bgp_neighbors[0].peer_ips[1]')
MY_ASN=$(echo $json | jq -r '.bgp_neighbors[0].peer_as')

ELASTIC_IP=$1

if grep --quiet 'lo:0' /etc/network/interfaces; then
  echo "lo:0 config already exists"
else
echo "
auto lo:0
  iface lo:0 inet static
  address $ELASTIC_IP
  netmask 255.255.255.255" >> /etc/network/interfaces
fi

read -r -d '' CONF  << EOM
filter packet_bgp {
  # the IP range(s) to announce via BGP from this machine
  # these IP addresses need to be bound to the lo interface
  # to be reachable; the default behavior is to accept all
  # prefixes bound to interface lo
  # if net = A.B.C.D/32 then accept;
  # IPs to announce ( ELASTIC IP $ELASTIC_IP in this case)
  # Doesn't have to be /32. Can be lower
  if net = $ELASTIC_IP/32 then accept;
}

router id $MY_PRIVATE_IP;

protocol direct {
  interface "lo"; # Restrict network interfaces BIRD works with
}

protocol kernel {
  #persist; # Don't remove routes on bird shutdown
  scan time 20; # Scan kernel routing table every 20 seconds
  import all; # Default is import all
  export all; # Default is export none
}

protocol static {
  #should always be 169.254.255.1 & 169.254.255.2
  route $MY_PEER_1/32 via $MY_PRIVATE_GW;
  route $MY_PEER_2/32 via $MY_PRIVATE_GW;
}

# This pseudo-protocol watches all interface up/down events.
protocol device {
  scan time 10; # Scan interfaces every 10 seconds
}

protocol bgp neighbor_v4_1 {
  export filter packet_bgp;
  local as 65000;
  multihop 5;
  neighbor $MY_PEER_1 as $MY_ASN;
}

protocol bgp neighbor_v4_2 {
  export filter packet_bgp;
  local as 65000;
  multihop 5;
  # ASN should always be 65530
  neighbor $MY_PEER_2 as $MY_ASN;
}
EOM

echo -e "$CONF" > /etc/bird/bird.conf

sysctl net.ipv4.ip_forward=1
ifup lo:0
service bird restart

