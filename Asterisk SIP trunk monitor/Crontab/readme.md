Copy installation script into Asterisk PBX.

chmod +x to make it an executable. #run as sudo user

./install_sip_trunk_monitor.sh #run as sudo user

The installation script takes care of making sure the crontab file is edited and the logfile is rotated. 

Logging can be found in /var/log/sip_trunk_monitor.log
