#!/bin/bash
#Sjoerd van Dijk 15-08-2023
#SIP Trunk Monitor using Crontab

# Set variables
SIP_TRUNK_IP="145.131.159.203"
MAX_RETRIES=5  # Maximum number of restart retries
RETRY_DELAY=60  # Initial retry delay in seconds
LOG_FILE="/var/log/sip_trunk_monitor.log"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to restart Asterisk
restart_asterisk() {
    sudo asterisk -rx "core restart now"
}

sip_registration_status=$(sudo asterisk -rx "sip show registry" | grep "$SIP_TRUNK_IP" | grep Registered)

if [[ -z "$sip_registration_status" ]]; then
    log_message "SIP trunk is not registered. Restarting Asterisk..."
    restart_asterisk
    log_message "Asterisk restarted."
    retry_count=0
    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        sleep $RETRY_DELAY
        sip_registration_status=$(sudo asterisk -rx "sip show registry" | grep "$SIP_TRUNK_IP" | grep Registered)
        if [[ -n "$sip_registration_status" ]]; then
            log_message "SIP trunk is registered after retry."
            break
        fi
        restart_asterisk
        log_message "Asterisk restarted during retry."
        ((retry_count++))
    done

    if [[ $retry_count -eq $MAX_RETRIES ]]; then
        log_message "SIP trunk could not be registered after $MAX_RETRIES retries. Manual intervention may be required."
    fi
else
    log_message "SIP trunk is registered."
fi
