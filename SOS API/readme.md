# SOSv3/v4 scripts

## SOS snapshot downloader
*Create a snapshot using the SOS API via curl, downloads the snapshot to device*

*Note: if you run the script as root using crontab the snapshots are stored to /home/root/. When you manually run the script the snapshots are saved to the location where the script is run*

- Supports iplist.txt
- Don't forget to change the credentials in the script!
- If it doesn't create the API request you probably need to update curl. 

## SOS sip event url checker
*Uses curl for the SOS API, outputs the sip event server url to the terminal*

- Supports iplist.txt
- Don't forget to change the credentials in the script!
- If it doesn't create the API request you probably need to update curl. 

## SOS Helpcom to CSV
*Useful if you want to list all the Helpcom devices to CSV*
- Supports iplist.txt
- Don't forget to change the credentials in the script!
- Requirements: jq, sshpass
