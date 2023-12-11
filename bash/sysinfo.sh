#!/bin/bash

#used the hostname command to get the fully qualified domain name
echo "FQDN: $(hostname -f)"

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

#it shows simple name of the machine
HOSTNAME=$(hostname)

#it will show qualified name of machine
FQDN=$(hostname -f)

#it will retrieve operating system as well as its version
OperatingSystem_Name=$(uname -s)
OperatingSystem_Version=$(uname -r)

#default ip address is used and awk is used to extract 7th field from output
IP_Address=$(ip route get 8.8.8.8 | awk '{print$7}')

#it will tell the available space on the root filesystem
RootSpace=$(df -h / | awk 'NR==2 {print $4}')

cat <<EOF

Report for $HOSTNAME
====================

Fully Qualified Domain Name: $FQDN
Operating System: $OperatingSystem_Name $OperatingSystem_Version
IP Address: $IP_Address
Root Filesystem Space: $RootSpace

==================
EOF
