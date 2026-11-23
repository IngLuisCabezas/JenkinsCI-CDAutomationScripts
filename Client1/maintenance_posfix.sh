#!/bin/bash

# Environment variables
export TZ="UTC"
export time_max=30

   timeout "$time_max" ssh -T "corp@xx.19.52.xx" <<EOF
   
#1.Delete All Mails in the Queue
sudo postsuper -d ALL
#You can verify the queue is empty:
mailq
#2.Clear Overgrown Local Mailboxes
sudo truncate -s 0 /var/mail/root
sudo truncate -s 0 /var/mail/c1dev1b
sudo truncate -s 0 /var/mail/c1_app
sudo truncate -s 0 /var/mail/corp
#3.Restart Postfix Service
sudo systemctl restart postfix 2>&1 
sleep 5
sudo systemctl status postfix 2>&1 

EOF

#v1.0 postfix