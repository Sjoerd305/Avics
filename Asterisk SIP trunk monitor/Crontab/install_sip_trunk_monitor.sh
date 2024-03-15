#!/bin/bash
#Sjoerd van Dijk 08-11-2023
#Install script for SIP trunk Monitor using Crontab

# Set up variables
INSTALL_DIR="/opt/sip_trunk_monitor"
LOG_DIR="/var/log"

# Create the installation directory
sudo mkdir -p "$INSTALL_DIR"

# Download the main script using wget
sudo wget -O "$INSTALL_DIR/sip_trunk_monitor.sh" "https://raw.githubusercontent.com/Sjoerd305/Avics/main/Asterisk%20SIP%20trunk%20monitor/Crontab/sip_trunk_monitor.sh"

# Make the script executable
sudo chmod +x "$INSTALL_DIR/sip_trunk_monitor.sh"

# Set up log rotation for the log file
sudo tee "/etc/logrotate.d/sip_trunk_monitor" > /dev/null <<EOF
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

# Add the cron job
CRON_JOB="*/5 * * * * $INSTALL_DIR/sip_trunk_monitor.sh"
(crontab -l ; echo "$CRON_JOB") | crontab -

echo "SIP Trunk Monitor installed successfully!"
