#!/bin/bash
#Sjoerd van Dijk 10-08-2023
#Monitor ongoing calls, if call exceeds two hours. Send hangup request. 

asterisk -rx "core show channels concise" | awk -F '!' '{print ($12 > 7200) ? "asterisk -rx \"channel request hangup "$1"\"" : "echo \""$1" "$12"\"" }' | bash
