#!/bin/bash

echo "unix_username=$UNIX_USERNAME ip_server=$IP_SERVER" > artifact.txt
ssh corp@$IP_SERVER "sudo passwd -u $UNIX_USERNAME; sudo getent passwd $UNIX_USERNAME; echo "<password>" | sudo -S passwd --stdin "$UNIX_USERNAME"; "  >> artifact.txt
