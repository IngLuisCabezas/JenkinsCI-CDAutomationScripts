#!/bin/bash

USER="client2-sv"
PASS="<password>"
HOST="xx.22.132.xx"

LOCAL_DIR="/nfs/home/cablui02-pa/tmp"
REMOTE_DIR="/IDBuildRelease/tmp"

curl --silent --show-error --user "$USER:$PASS" -Q "mkdir $REMOTE_DIR" sftp://$HOST/ >/dev/null  2>&1

if [ $? -ne 0 ]; then
echo "[Error]:Something was wrong creating the Release ID Build Directory for ENV on SFTP Server, Looks like this release Job has been already uploaded. Please Check it. ";
exit 1;
fi

# Loop through all files in local directory and upload them
for FILE in "$LOCAL_DIR"/*; do
  FILENAME=$(basename "$FILE")
  echo "Uploading $FILENAME..."
  curl -sS -T "$FILE" --user "$USER:$PASS" "sftp://$HOST$REMOTE_DIR/$FILENAME"
done

echo "Email and explanation everyithong is up"
