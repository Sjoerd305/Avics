#!/bin/bash
#Requirements: jq, sshpass
# Sjoerd van Dijk @ 2024

##############################
# iplist.txt in following format name,ip
#DON'T USE SPACES
##############################

USERNAME="account"
PASSWORD="password"
REMOTE_FILE_PATH="/etc/kxa/json/helpcom-objects.json"
OUTPUT_FILE="output.csv"

# Initialize the output file
echo "Name,IP Address,SSID,Source Event,Target Object,Target Source,Target Event,Description" > "$OUTPUT_FILE"

parse_json_to_csv() {
    local name=$1
    local ip=$2
    local json_content=$3

    if [ ! -z "$json_content" ]; then
        echo "$json_content" | jq -r --arg IP "$ip" --arg NAME "$name" '.[] | .ssid as $ssid | .["helpcom-mappings"][] | [$NAME, $IP, $ssid, .["source-event"], .["target-object"], .["target-source"], .["target-event"], .description] | @csv' >> "$OUTPUT_FILE"
    fi
}

log_failure() {
    local name=$1
    local ip=$2
    # Log the failure to process IP
    echo "\"$name\",\"$ip\",N/A,N/A,N/A,N/A,N/A,\"Failed to process IP\"" >> "$OUTPUT_FILE"
}

while IFS=, read -r name ip; do
    echo "Attempting to process $ip ($name)..."
    json_data=$(sshpass -p "$PASSWORD" ssh -n -o StrictHostKeyChecking=no "$USERNAME@$ip" "cat $REMOTE_FILE_PATH" 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "Processing $ip ($name)..."
        parse_json_to_csv "$name" "$ip" "$json_data"
    else
        echo "Failed to process $ip ($name)."
        log_failure "$name" "$ip"
    fi
done < "iplist.txt"

echo "Processing completed. Output saved in $OUTPUT_FILE."
