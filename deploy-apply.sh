#!/bin/bash
# set -ex

echo """
 ____ _____  _    ____ _____ ___ _   _  ____ 
/ ___|_   _|/ \  |  _ \_   _|_ _| \ | |/ ___|
\___ \ | | / _ \ | |_) || |  | ||  \| | |  _ 
 ___) || |/ ___ \|  _ < | |  | || |\  | |_| |
|____/ |_/_/__ \_\_| \_\|_| |___|_| \_|\____|
| \ | | ____\ \      / /                     
|  \| |  _|  \ \ /\ / /                      
| |\  | |___  \ V  V /                       
|_| \_|_____|  \_/\_/                                                                  
"""

sudo -S --validate
# 

# Stop the service
echo "Stopping the service..."
# Stop Service Named: boringnewsletters
sudo service boringnewsletters stop

# Delete the directory named "app"
echo "Deleting the directory named 'planet'..."
rm -rf planet

# Rename another folder named "app_red" to "app"
echo "Renaming 'planet_red' folder to 'planet'..."
mv planet_red planet

#  TODO Add Migrate Step

# Start the service
echo "Starting the service..."
sudo service boringnewsletters start

# Check if the service is active
while ! systemctl is-active --quiet boringnewsletters.service; do
    echo "Waiting for the service to start..."
    sleep 5
done

echo "Show the service logs..."
journalctl -u boringnewsletters.service -b  -n 20 --no-pager

echo "Service restart complete.\n"
