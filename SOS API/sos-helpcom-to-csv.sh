#!/bin/bash
#Requirements
# jq, sshpass

# Sjoerd van Dijk @ 2024

USERNAME="account"
PASSWORD="password"
REMOTE_FILE_PATH="/etc/kxa/json/helpcom-objects.json"
OUTPUT_FILE="output.csv"

# Initialize the output file
echo "IP Address,SSID,Source Event,Target Object,Target Source,Target Event,Description" > "$OUTPUT_FILE"

# Function to parse JSON and convert to CSV using jq
parse_json_to_csv() {
    local ip=$1
    local json_content=$2

    echo "$json_content" | jq -r --arg IP "$ip" '.[] | .ssid as $ssid | .["helpcom-mappings"][] | [$IP, $ssid, .["source-event"], .["target-object"], .["target-source"], .["target-event"], .description] | @csv' >> "$OUTPUT_FILE"
}

# Read each IP from the list and process
while IFS= read -r ip
do
    echo "Attempting to process $ip..."
    json_data=$(sshpass -p "$PASSWORD" ssh -n -o StrictHostKeyChecking=no "$USERNAME@$ip" "cat $REMOTE_FILE_PATH" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "Processing $ip..."
        parse_json_to_csv "$ip" "$json_data"
    else
        echo "Failed to process $ip."
    fi
done < "iplist.txt"

echo "Processing completed. Output saved in $OUTPUT_FILE."
