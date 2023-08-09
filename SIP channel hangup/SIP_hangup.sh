#!/bin/bash

LOG_FILE="/var/log/hangup_calls.log"

while true; do
    active_calls=$(asterisk -rx "core show channels concise" | awk '$6 > 7200 {print $1}')
    
    for call_id in $active_calls; do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$timestamp - Hanging up call $call_id" >> "$LOG_FILE"
        asterisk -rx "channel request hangup $call_id"
    done
    
    sleep 300  # Sleep for 5 minutes before checking again
done
