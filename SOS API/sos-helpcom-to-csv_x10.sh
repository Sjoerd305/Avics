#!/bin/bash
#Requirements: jq, sshpass, xargs
# Sjoerd van Dijk @ 2024

USERNAME="account"
PASSWORD="password"
REMOTE_FILE_PATH="/etc/kxa/json/helpcom-objects.json"
OUTPUT_FILE="output.csv"

# Initialize the output file
echo "IP Address,SSID,Source Event,Target Object,Target Source,Target Event,Description" > "$OUTPUT_FILE"

parse_json_to_csv() {
    local ip=$1
    local json_content=$2

    # Parse JSON content to CSV only if it's not empty
    if [ ! -z "$json_content" ]; then
        echo "$json_content" | jq -r --arg IP "$ip" '.[] | .ssid as $ssid | .["helpcom-mappings"][] | [$IP, $ssid, .["source-event"], .["target-object"], .["target-source"], .["target-event"], .description] | @csv' >> "$OUTPUT_FILE"
    fi
}

log_failure() {
    local ip=$1
    # Log the failure to process IP
    echo "\"$ip\",N/A,N/A,N/A,N/A,N/A,\"Failed to process IP\"" >> "$OUTPUT_FILE"
}

export -f parse_json_to_csv
export -f log_failure
export USERNAME PASSWORD REMOTE_FILE_PATH OUTPUT_FILE

process_ip() {
    ip=$1
    echo "Attempting to process $ip..."
    json_data=$(sshpass -p "$PASSWORD" ssh -n -o StrictHostKeyChecking=no "$USERNAME@$ip" "cat $REMOTE_FILE_PATH" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Processing $ip..."
        parse_json_to_csv "$ip" "$json_data"
    else
        echo "Failed to process $ip."
        log_failure "$ip"
    fi
}

export -f process_ip
cat "iplist.txt" | xargs -I {} -P 10 -n 1 bash -c 'process_ip "$@"' _ {}

echo "Processing completed. Output saved in $OUTPUT_FILE."
