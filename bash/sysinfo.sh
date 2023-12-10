#!/bin/bash


echo "FQDN: $(hostname)"


echo "Host Information:"
hostnamectl | grep "Static hostname\|Icon name\|Chassis\|Machine ID\|Boot ID\|Operating System\|Kernel\|Architecture"


echo "IP aDDRESSES:"
ip -o addr show | awk '$3 != "lo" {print $4}'


echo "Root Filesystem Status:"
df -h / | awk 'NR==2 {print "Filesystem: "$1, "Size: "$2, "Used: "$3, "Avail: "$4,"Use%: "$5, "Mounted on: "$6}'
