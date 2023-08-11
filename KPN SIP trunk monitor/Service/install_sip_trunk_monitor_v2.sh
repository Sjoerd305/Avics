#!/bin/bash
#Sjoerd van Dijk 11-08-2023
#Install SIP Trunk Monitor as a Service

# Set variables
INSTALL_DIR="/opt/sip_trunk_monitor"
SCRIPT_NAME="sip_trunk_monitor.sh"
SERVICE_NAME="sip_trunk_monitor.service"
SCRIPT_SOURCE="sip_trunk_monitor.sh"

# Create the installation directory
sudo mkdir -p $INSTALL_DIR

# Copy the script file
sudo cp $SCRIPT_SOURCE $INSTALL_DIR/$SCRIPT_NAME

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
