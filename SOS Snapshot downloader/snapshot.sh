#!/bin/bash
# Sjoerd van Dijk
# Avics B.V.
# @2024

# Array of IP addresses
ip_addresses="iplist.txt"

username="account"
password="password"
snapshot_endpoint="/take-snapshot/"

for ip_address in "${ip_addresses[@]}"; do
    # URL for the snapshot API (HTTPS and port 4443)
    api_url="https://${ip_address}:4443${snapshot_endpoint}"

    # URL for downloading the snapshot
    download_url="http://${ip_address}/snapshots/snapshot.jpg"

    # Output file for the snapshot
    output_file="${ip_address}_$(date +"%Y%m%d_%H%M%S").jpg"

    # Make the API request to create the snapshot
    curl --insecure -u "${username}:${password}" "${api_url}"

    # Check if the request was successful
    if [ $? -eq 0 ]; then
        echo "Snapshot request sent for ${ip_address}. Waiting for 5 seconds..."

        # Wait for 5 seconds
        sleep 5

        # Download the snapshot
        curl --insecure -o "${output_file}" "${download_url}"

        # Check if the download was successful
        if [ $? -eq 0 ]; then
            echo "Snapshot for ${ip_address} downloaded and saved to ${output_file}"
        else
            echo "Error: Unable to download the snapshot for ${ip_address}. Check the download URL."
        fi
    else
        echo "Error: Unable to create snapshot for ${ip_address}. Check your API request or credentials."
    fi
done
