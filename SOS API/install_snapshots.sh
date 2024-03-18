#!/bin/bash
# Sjoerd van Dijk @ 2024

#Variables
SOS_VERSION="3" # 3 or 4
CRON="0 1 19 * *" # Minute, Hour, Day, Month, DayofWeek

INSTALL_DIR="/opt/scripts"
SNAPSHOT_DIR="/opt/scripts/snapshot"
CRON_JOB="$CRON $INSTALL_DIR/sosv$SOS_VERSION-download-snapshot.sh" #Change cron job as needed

#Create directories
mkdir $INSTALL_DIR
mkdir $SNAPSHOT_DIR

#Feth script from Github
wget -O "$INSTALL_DIR/sosv$SOS_VERSION-download-snapshot.sh" "https://raw.githubusercontent.com/Sjoerd305/Avics/main/SOS%20API/sosv$SOS_VERSION-download-snapshot.sh" || { echo "Failed to download the script"; exit 1; }

#Mark script as executable
chmod +x $INSTALL_DIR/sosv$SOS_VERSION-download-snapshot.sh

#Create iplist
touch $INSTALL_DIR/iplist.txt

#Create cron job
if ! crontab -l | grep -Fq "$CRON_JOB" ; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab - || { echo "Failed to add cron job"; exit 1; }
fi

echo "Installation complete!"