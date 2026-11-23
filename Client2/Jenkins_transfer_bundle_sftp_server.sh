#!/bin/bash

USER="client2-sv"
PASS="<password>"
HOST="xx.22.132.xx"

LOCAL_DIR="/c2/c2_app/jenkinsv2/jenkins/jobs/${UPSTREAM_JOB_NAME}/builds/${UPSTREAM_BUILD_NUMBER}/archive"
REMOTE_DIR="/IDBuildRelease/${UPSTREAM_JOB_NAME}/${UPSTREAM_BUILD_NUMBER}"

curl --silent --show-error --user "$USER:$PASS" -Q "mkdir $REMOTE_DIR" sftp://$HOST/ >/dev/null  2>&1

if [ $? -ne 0 ]; then
echo "[Error]:Something was wrong creating the Release ID Build Directory ${UPSTREAM_BUILD_NUMBER} for ${UPSTREAM_JOB_NAME} on SFTP Server, Looks like this release Job has been already uploaded. Please Check it. ";
exit 1;
fi

# Loop through all files in local directory and upload them
for FILE in "$LOCAL_DIR"/*; do
  FILENAME=$(basename "$FILE")
  echo "Uploading $FILENAME..."
  curl -sS -T "$FILE" --user "$USER:$PASS" "sftp://$HOST$REMOTE_DIR/$FILENAME"
done

mail \
    -s " Transfered Jenkins Job:${UPSTREAM_JOB_NAME} Buid ID:${UPSTREAM_BUILD_NUMBER} Bundle to sftp01-oma server" \
    user01@company.com <<EOF
Hi Client2 Release Management Team,

Newer ${UPSTREAM_JOB_NAME} has been saved on sftp01-oma server. 

Directory:/IDBuildRelease/${UPSTREAM_JOB_NAME}/${UPSTREAM_BUILD_NUMBER}

This is an automated message. If you have any questions or need assistance, please contact the PE team at:  
List-Client2PlatformEngineering@company.com
EOF
