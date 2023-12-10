#!/bin/bash

#used the hostname command to get the fully qualified domain name
echo "FQDN: $(hostname)"

#displaying host information
echo "Host Information:"
#i have used hostnamectl to get the information about the host and grep is used to filter the relevant details
hostnamectl | grep "Static hostname\|Icon name\|Chassis\|Machine ID\|Boot ID\|Operating System\|Kernel\|Architecture"

#here I have used the comamnd to show ip address and awk is for filtering out loopback addresses
echo "IP aDDRESSES:"
ip -o addr show | awk '$3 != "lo" {print $4}'

#displaying root filesystem
echo "Root Filesystem Status:"
#df is used to tell disk space usage and awk to format and print relevant information for root filesystem
df -h / | awk 'NR==2 {print "Filesystem: "$1, "Size: "$2, "Used: "$3, "Avail: "$4,"Use%: "$5, "Mounted on: "$6}'
