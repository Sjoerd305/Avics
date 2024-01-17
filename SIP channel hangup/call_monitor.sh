#!/bin/bash
#Sjoerd van Dijk 26-01-2024

#Monitor ongoing calls, if call exceeds two hours. Send hangup request. 

asterisk -rx "core show channels concise" | awk -F '!' '{print ($12 > 7200) ? "asterisk -rx \"channel request hangup "$1"\"" : "echo \""$1" "$12"\"" }' | bash >> /var/log/call_monitor.log 2>&1