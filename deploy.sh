#!/bin/bash
# set -ex

# Check if the filename is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Get the filename from the command line argument
LOCAL_FILE="$1"
LOCAL_FILE_NAME="${LOCAL_FILE##*/}"
echo $LOCAL_FILE_NAME

DEPLOY_APPLY_SCRIPT="deploy-apply.sh"

REMOTE_SSH_ALIAS="rn"
REMOTE_DIR="/home/deploy/releases"

# Copy the file to the remote server using SSH
echo "Copying $LOCAL_FILE to remote server..."
scp "$LOCAL_FILE" "$REMOTE_SSH_ALIAS:$REMOTE_DIR"
scp "$DEPLOY_APPLY_SCRIPT" "$REMOTE_SSH_ALIAS:$REMOTE_DIR"


# Connect to the remote server and unzip the file
echo "Connecting to the remote server..."
ssh "$REMOTE_SSH_ALIAS" "cd $REMOTE_DIR && rm -rf planet_red && mkdir -p planet_red && tar -zxvf $LOCAL_FILE_NAME -C planet_red/ && mkdir -p compressed/ && mv $LOCAL_FILE_NAME compressed/"

echo "Make sure to apply the deploy script inside the remote server"
echo "bash deploy-apply.sh"

echo "File copied, extracted, and ready to deploy"


echo """
  ____  _____ __  __  ___ _____ _____  
 |  _ \| ____|  \/  |/ _ \_   _| ____| 
 | |_) |  _| | |\/| | | | || | |  _|   
 |  _ <| |___| |  | | |_| || | | |___  
 |_|_\_\_____|_|__|_|\___/_|_|_|_____| 
 / ___|| ____|  _ \ \   / / ____|  _ \ 
 \___ \|  _| | |_) \ \ / /|  _| | |_) |
  ___) | |___|  _ < \ V / | |___|  _ < 
 |____/|_____|_| \_\ \_/  |_____|_| \_\                                   
 """
echo "Logging you into remove server inside working directory"
ssh -t rn "cd $REMOTE_DIR ; bash --login"


