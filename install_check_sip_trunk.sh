#!/bin/bash

# Script to install SIP trunk monitoring and log rotation

# Set variables
SIP_TRUNK_IP="145.131.159.203"
INSTALL_DIR="/opt/sip_trunk_monitor"
LOG_FILE="/var/log/check_sip_trunk.log"
CRON_JOB="*/5 * * * * $INSTALL_DIR/check_sip_trunk.sh"

# Create the installation directory
sudo mkdir -p $INSTALL_DIR

# Create the script file
cat <<EOT > $INSTALL_DIR/check_sip_trunk.sh
#!/bin/bash

# Check SIP registration status
sip_registration_status=\$(sudo asterisk -rx "sip show registry" | grep "$SIP_TRUNK_IP")

if [[ -z "\$sip_registration_status" ]]; then
    log_message="[\$(date '+%Y-%m-%d %H:%M:%S')] SIP trunk is not registered. Restarting Asterisk..."
    echo "\$log_message" >> "$LOG_FILE"
    sudo asterisk -rx "core restart now"
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Asterisk restarted." >> "$LOG_FILE"
else
    log_message="[\$(date '+%Y-%m-%d %H:%M:%S')] SIP trunk is registered."
    echo "\$log_message" >> "$LOG_FILE"
fi
EOT

# Add execution permissions to the script
sudo chmod +x $INSTALL_DIR/check_sip_trunk.sh

# Create logrotate configuration
echo "/var/log/check_sip_trunk.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}" | sudo tee /etc/logrotate.d/check_sip_trunk > /dev/null

# Add cron job
(crontab -l ; echo "$CRON_JOB") | crontab -

echo "Installation completed successfully!"