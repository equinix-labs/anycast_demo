#!/bin/bash

ANYCAST=$1

apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get install -y bird golang jq >/dev/null 2>&1
bash ./create_bird_conf.sh "$ANYCAST"
# go build web.go ; nohup ./web & 
exit
