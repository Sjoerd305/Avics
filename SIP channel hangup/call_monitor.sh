#!/bin/bash
#Sjoerd van Dijk 10-08-2023
#Monitor ongoing calls, if call exceeds two hours. Send hangup request. 

LOG_FILE="/var/log/hangup_calls.log"

while true; do
    active_calls=$(asterisk -rx "core show channels concise" | awk '$6 > 7200 {print}')

    for call in "$active_calls"; do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$timestamp - Active call details: $call" >> "$LOG_FILE"
        channel=$(echo "$call" | awk '{print $1}')
        echo "$timestamp - Hanging up call on channel $channel" >> "$LOG_FILE"
        asterisk -rx "channel request hangup all"
    done

    sleep 300  # Sleep for 5 minutes before checking again
done
