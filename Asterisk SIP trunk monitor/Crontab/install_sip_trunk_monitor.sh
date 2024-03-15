#!/bin/bash
# Sjoerd van Dijk 15-03-2024
# Install script for SIP Trunk Monitor using Crontab

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Set up variables
INSTALL_DIR="/opt/sip_trunk_monitor"
LOG_DIR="/var/log"
CRON_JOB="*/5 * * * * $INSTALL_DIR/sip_trunk_monitor.sh"

# Create the installation directory
mkdir -p "$INSTALL_DIR" || { echo "Failed to create installation directory"; exit 1; }

# Download the main script using wget
wget -O "$INSTALL_DIR/sip_trunk_monitor.sh" "https://raw.githubusercontent.com/Sjoerd305/Avics/main/Asterisk%20SIP%20trunk%20monitor/Crontab/sip_trunk_monitor.sh" || { echo "Failed to download the script"; exit 1; }

# Make the script executable
chmod +x "$INSTALL_DIR/sip_trunk_monitor.sh" || { echo "Failed to make the script executable"; exit 1; }

# Set up log rotation for the log file
tee "/etc/logrotate.d/sip_trunk_monitor" > /dev/null <<EOF || { echo "Failed to set up log rotation"; exit 1; }
$LOG_DIR/sip_trunk_monitor.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
}
EOF

# Add the cron job if it doesn't already exist
if ! crontab -l | grep -Fq "$CRON_JOB" ; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab - || { echo "Failed to add cron job"; exit 1; }
fi

echo "SIP Trunk Monitor installed successfully!"
