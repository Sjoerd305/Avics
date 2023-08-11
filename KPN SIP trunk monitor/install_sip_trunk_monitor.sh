#!/bin/bash
# Sjoerd van Dijk 11-08-2023
# Installs SIP trunk Monitor as a Service.
# Monitors IP 145.131.159.203 every 5 minutes.

# Set variables
INSTALL_DIR="/opt/sip_trunk_monitor"
SCRIPT_NAME="sip_trunk_monitor.sh"
SERVICE_NAME="sip_trunk_monitor.service"
LOG_FILE="/var/log/sip_trunk_monitor.log"

# Create the installation directory
sudo mkdir -p $INSTALL_DIR

# Create the script file
cat <<EOT > $INSTALL_DIR/$SCRIPT_NAME
#!/bin/bash

# Set variables
SIP_TRUNK_IP="145.131.159.203"
MAX_RETRIES=5  # Maximum number of restart retries
RETRY_DELAY=15  # Initial retry delay in seconds

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] \$1" >> "$LOG_FILE"
}

# Function to restart Asterisk
restart_asterisk() {
    sudo asterisk -rx "core restart now"
}

while true; do
    sip_registration_status=\$(sudo asterisk -rx "sip show registry" | grep "\$SIP_TRUNK_IP")

    if [[ -z "\$sip_registration_status" ]]; then
        log_message "SIP trunk is not registered. Restarting Asterisk..."
        restart_asterisk
        log_message "Asterisk restarted."
        retry_count=0
        while [[ \$retry_count -lt \$MAX_RETRIES ]]; do
            sleep \$RETRY_DELAY
            sip_registration_status=\$(sudo asterisk -rx "sip show registry" | grep "\$SIP_TRUNK_IP")
            if [[ -n "\$sip_registration_status" ]]; then
                log_message "SIP trunk is registered after retry."
                break
            fi
            ((retry_count++))
        done

        if [[ \$retry_count -eq \$MAX_RETRIES ]]; then
            log_message "SIP trunk could not be registered after \$MAX_RETRIES retries. Manual intervention may be required."
        fi
    else
        log_message "SIP trunk is registered."
    fi

    sleep 300  # Wait for 5 minutes before checking again
done

EOT

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

# Create logrotate configuration for the log file
echo "$LOG_FILE {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}" | sudo tee /etc/logrotate.d/sip_trunk_monitor > /dev/null

# Add execution permissions to the script
sudo chmod +x $INSTALL_DIR/$SCRIPT_NAME

# Reload systemd manager configuration
sudo systemctl daemon-reload

# Start and enable the service
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

echo "Installation completed successfully!"
echo "The sip_trunk_monitor service has started"
echo "Log can be viewed at $LOG_FILE"
