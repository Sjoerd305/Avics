#!/bin/bash

# Set variables
INSTALL_DIR="/opt/sip_trunk_monitor"
SCRIPT_NAME="sip_trunk_monitor.sh"
SERVICE_NAME="sip_trunk_monitor.service"
SCRIPT_URL="https://raw.githubusercontent.com/Sjoerd305/Avics/main/KPN%20SIP%20trunk%20monitor/Service/sip_trunk_monitor.sh"  # Replace with the actual HTTPS URL of your script

# Create the installation directory
sudo mkdir -p $INSTALL_DIR

# Download the script file
sudo curl -o $INSTALL_DIR/$SCRIPT_NAME $SCRIPT_URL

# Create the service unit file
cat <<EOT > /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=SIP Trunk Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$SCRIPT_NAME
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# Add execution permissions to the script
sudo chmod +x $INSTALL_DIR/$SCRIPT_NAME

# Reload systemd manager configuration
sudo systemctl daemon-reload

# Start and enable the service
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

echo "Installation completed successfully!"
echo "The sip_trunk_monitor service has started"
