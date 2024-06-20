#!/bin/bash
#Requirements: sshpass

# Ensure the script is run as root on the local machine
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Ensure sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass is not installed. Please install it and run the script again."
  exit 1
fi

# Read the list of IP addresses from iplist.txt
if [ ! -f iplist.txt ]; then
  echo "iplist.txt file not found!"
  exit 1
fi

servers=()
while IFS= read -r line; do
  servers+=("$line")
done < iplist.txt

# Define the username and password
username="your_username"
password="your_password"

# Define the NTP configuration content
ntp_config_content="[Time]
NTP=10.66.96.8
"

# Define the NTP configuration file path
ntp_file="/etc/systemd/timesyncd.conf.d/custom_ntp.conf"
config_dir="/etc/systemd/timesyncd.conf.d"

# Loop over each server and apply the configuration
for server in "${servers[@]}"; do
  echo "Updating NTP configuration on $server"

  sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$server" "
    echo '$password' | sudo -S bash -c '
      set -e
      mkdir -p $config_dir
      rm -f $config_dir/*.conf
      echo \"Removed existing .conf files in $config_dir\"
      echo \"$ntp_config_content\" | tee $ntp_file > /dev/null
      echo \"NTP configuration was written to $ntp_file\"
      echo \"Restarting systemd-timesyncd service...\"
      systemctl daemon-reload
      systemctl restart systemd-timesyncd
      echo \"systemd-timesyncd service restarted successfully\"
    '
  "

  if [ $? -eq 0 ]; then
    echo "NTP configuration update completed successfully on $server"
  else
    echo "Failed to update NTP configuration on $server"
  fi
done
