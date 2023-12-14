#!/bin/bash

#function for logging an error message with timestamp and display it
function errormessage() {
#this shows current timestamp in the following pattern
    local timestamp=$(date +"%Y-%m-%d %T")
#creation of formatted error message
    local ErrorMessage="Error: $1"
#log the error message with timestamp to logfile
    echo "[$timestamp] $ErrorMessage" >> /var/log/systeminfo.log
#displaying the error messag eto the user
    echo "$ErrorMessage" >&2
}
#function for generating report for CPU
function cpu_report() {
    echo "=============="
    echo "CPU REPORT"
    echo "=============="
# Extract and display CPU information
    echo "CPU Manufacturer and Model: $(lscpu | grep "Model name" | cut -d':' -f2 | xargs)"
    echo "CPU Architecture: $(lscpu | grep "Architecture" | cut -d':' -f2 | xargs)"
    echo "CPU Core Count: $(lscpu | grep "Core(s) per socket" | cut -d':' -f2 | xargs)"
    echo "CPU Maximum Speed: $(lscpu | grep "Max Speed" | cut -d':' -f2 | xargs)"
# Display Cache Sizes and display all 3 cache informtaion
    echo "Cache Sizes:"
    echo "  L1 Cache: $(lscpu | grep "L1d cache" | cut -d':' -f2 | xargs)"
    echo "  L2 Cache: $(lscpu | grep "L2 cache" | cut -d':' -f2 | xargs)"
    echo "  L3 Cache: $(lscpu | grep "L3 cache" | cut -d':' -f2 | xargs)"
}

#heading for computer report
function ComputerReport() {
    echo "================"
    echo "COMPUTER REPORT"
    echo "================"
    echo "Title: Computer Info"

# Displaying the Computer information using awk and hostnamectl 
    echo "Computer Manufacturer: $(hostnamectl | awk -F': ' '/Chassis/ {print $2}')"
    echo "Computer Description: $(hostnamectl | awk -F': ' '/Machine ID/ {print $2}')"
    echo "Computer Serial Number: $(hostnamectl | awk -F': ' '/System Serial Number/ {print $2}')"
}
# Function to generate an operating system report
function os_report() {
    echo "============"
    echo "OS REPORT"
    echo "============"
    echo "Title: Operating System Info"
# Extracting and displaying the Linux distribution and its version using lsb_release command
    echo "Linux Distro: $(lsb_release -si)"
    echo "Distro Version: $(lsb_release -sr)"
}

function ram_report() {
    echo "=============="
    echo "RAM REPORT"
    echo "=============="
    echo "Installed Memory Components:"
    echo "Manufacturer | Model | Size | Speed | Location"
    echo "------------------------------------------------"
 # Using dmidecode to extract and format information about Memory Devices
    dmidecode -t memory | grep -A6 "Memory Device" | awk 'NR%7==1 {manufacturer=$2} NR%7==2 {model=$2} NR%7==3 {size=$2} NR%7==4 {speed=$2} NR%7==6 {print manufacturer" | "model" | "size" | "speed" | "$2}' | column -t
# Display the Total Installed RAM using free command
    echo "Total Installed RAM: $(free -h | grep "Mem:" | awk '{print $2}')"
}

#function to generate a video report
function video_report() {
    echo "============"
    echo "VIDEO REPORT"
    echo "============"
    echo "Title: Video Info"
# Use lspci to get information about the Video Card/Chipset Manufacturer
    manufacturer=$(lspci | grep VGA | awk -F: '{print $3}' | tr -d '[:space:]')
    echo "Video Card/Chipset Manufacturer: $manufacturer"
# Use lspci to get information about the Video Card/Chipset Description
    description=$(lspci | grep VGA | awk -F: '{print $2}' | tr -d '[:space:]')
    echo "Video Card/Chipset Description: $description"

}
#function to generate a disk report
function disk_report() {
    echo "=============="
    echo "DISK REPORT"
    echo "=============="
    echo "Installed Disk Drives:"
# Display the column headers for Manufacturer, Model, Size, Partition, Mount Point, Filesystem Size, and Filesystem Type
    echo "Manufacturer | Model | Size | Partition | Mount Point | Filesystem Size | Filesystem Free Space"
    echo "---------------------------------------------------------------------------------------------"
# Used lsblk to get information about installed disk drives and format the output
    lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINT | awk '$1~/^sd/ {print $2" | "$3" | "$4" | "$1" | "$5" | "$6}' | column -t
}

#function to  generate network report
function network_report() {
    echo "============"
    echo "NETWORK REPORT"
    echo "============"
    echo "Title: Network Info"
    echo "Installed Network Interfaces:"
    echo "Interface | Manufacturer | Model/Description | Link State | Current Speed | IP Addresses | Bridge Master | DNS Servers | Search Domains"
    echo "-------------------------------------------------------------------"
# Used ip command to get a list of installed network interfaces
    interfaces=$(ip -o link show | awk -F': ' '{print $2}')

# Iterate over each network interface
    for interface in $interfaces; do
# Used ethtool to get information about the network interface's
        manufacturer=$(ethtool -i "$interface" 2>/dev/null | grep "driver:" | awk '{print $2}')
        model=$(ethtool -i "$interface" 2>/dev/null | grep "version:" | awk '{print $2}')
        linkstate=$(ethtool "$interface" 2>/dev/null | grep "Link detected:" | awk '{print $3}')
# Get the current speed of the network interface (or display "N/A" if not available)
        speed=$(cat "/sys/class/net/$interface/speed" 2>/dev/null || echo "N/A")
# Get the IP addresses assigned to the network interface
        ipaddresses=$(ip -4 addr show dev "$interface" | awk '/inet / {print $2}')
# Getting the bridge master information (or display "N/A" if not available)
        bridgemaster=$(cat "/sys/class/net/$interface/master" 2>/dev/null || echo "N/A")
# Get DNS server and domain information using systemd-resolve
        dnsservers=$(systemd-resolve --interface="$interface" --status 2>/dev/null | awk '/DNS Servers:/ {print $3}')
        searchdomains=$(systemd-resolve --interface="$interface" --status 2>/dev/null | awk '/Domains:/ {print $2}')
# Displaying the information for the current network interface
        echo "$interface | $manufacturer | $model | $linkstate | $speed | $ipaddresses | $bridgemaster | $dnsservers | $searchdomains"
    done
}
