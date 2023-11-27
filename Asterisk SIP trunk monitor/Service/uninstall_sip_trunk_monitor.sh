#!/bin/bash
#Sjoerd van Dijk 11-08-2023
#Uninstall SIP Turnk Monitor Service

# Set variables
INSTALL_DIR="/opt/sip_trunk_monitor"
SERVICE_NAME="sip_trunk_monitor.service"
LOG_FILE="/var/log/sip_trunk_monitor.log"

# Stop and disable the service
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME

# Remove the service unit file
sudo rm -f /etc/systemd/system/$SERVICE_NAME

# Remove the logrotate configuration
sudo rm -f /etc/logrotate.d/sip_trunk_monitor

# Remove the installation directory and script
sudo rm -rf $INSTALL_DIR

# Remove the log file
sudo rm -f $LOG_FILE

echo "Uninstallation completed successfully!"
