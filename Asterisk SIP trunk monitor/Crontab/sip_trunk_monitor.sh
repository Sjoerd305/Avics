#!/bin/bash
# Sjoerd van Dijk 15-03-2024
# SIP Trunk Monitor using Crontab

# Set variables
SIP_TRUNK_IP="145.131.159.203" #Change this IP address to the desired SIP trunk IP
MAX_RETRIES=5
RETRY_DELAY=60
LOG_FILE="/var/log/sip_trunk_monitor.log"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to restart Asterisk
restart_asterisk() {
    asterisk -rx "core restart now"
}

# Function to reload Asterisk
reload_asterisk() {
    asterisk -rx "core reload"
}

# Check if run as root
if [ "$(id -u)" -ne 0 ]; then
   log_message "This script must be run as root" 1>&2
   exit 1
fi

# Check Asterisk CLI availability
if ! command -v asterisk &> /dev/null; then
    log_message "Asterisk CLI could not be found. Please ensure Asterisk is installed." 1>&2
    exit 2
fi

sip_registration_status=$(asterisk -rx "sip show registry" | grep "$SIP_TRUNK_IP" | grep Registered)

if [[ -z "$sip_registration_status" ]]; then
    log_message "SIP trunk is not registered."
    reload_asterisk
    log_message "Asterisk reloaded."
    retry_count=0
    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        sleep $RETRY_DELAY
        sip_registration_status=$(asterisk -rx "sip show registry" | grep "$SIP_TRUNK_IP" | grep Registered)
        if [[ -n "$sip_registration_status" ]]; then
            log_message "SIP trunk is registered after core reload. Retry count: $retry_count"
            break
        fi
        restart_asterisk
        log_message "Asterisk restarted during retry $retry_count."
        ((retry_count++))
    done

    if [[ $retry_count -eq $MAX_RETRIES ]]; then
        log_message "SIP trunk could not be registered after $MAX_RETRIES retries. Manual intervention may be required."
        exit 3
    fi
fi