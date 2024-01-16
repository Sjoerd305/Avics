#!/bin/bash

# File containing the list of IP addresses, one per line
IP_FILE="iplist.txt"

# Username and password for authentication
USERNAME="username"
PASSWORD="password"

# Function to perform the curl request and extract sip-event-server-url
get_sip_event_server_url() {
    IP=$1
    URL="https://${IP}:4443/audio-settings/"
    #OUTPUT=$(curl --insecure -u $URL)
    OUTPUT=$(curl --insecure -u "${USERNAME}:${PASSWORD}" "${URL}")
    # Extracting sip-event-server-url using awk
    SIP_EVENT_SERVER_URL=$(echo "$OUTPUT" | awk -F'"sip-event-server-url":' '{split($2, a, /[",]/); gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[2]); print a[2]}')
    
    echo "IP: $IP - SIP Event Server URL: $SIP_EVENT_SERVER_URL"
}

# Check if the IP file exists
if [ ! -f "$IP_FILE" ]; then
    echo "IP address file not found: $IP_FILE"
    exit 1
fi

# Read IP addresses from the file and process each one
while IFS= read -r IP; do
    get_sip_event_server_url "$IP"
done < "$IP_FILE"
