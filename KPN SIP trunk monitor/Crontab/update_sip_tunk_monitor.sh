#!/bin/bash
#Sjoerd van Dijk 08-11-2023
#Update SIP trunk monitor

INSTALL_DIR="/opt/sip_trunk_monitor"
UPDATE_URL="https://raw.githubusercontent.com/Sjoerd305/Avics/main/KPN%20SIP%20trunk%20monitor/Crontab/sip_trunk_monitor.sh"

sudo wget -O "$INSTALL_DIR/sip_trunk_monitor.sh" "$UPDATE_URL"
sudo chmod +x "$INSTALL_DIR/sip_trunk_monitor.sh"

echo "SIP trunk monitor updated!"