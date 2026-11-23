#!/bin/bash

# Enable debug mode
# set -x

# Environment variables
export TZ="UTC"
envs="envs: $ENV_LIST"
IFS=',' read -ra user_array <<< "$USER_NAMES"
IFS=',' read -ra name_array <<< "$NAMES"
IFS=',' read -ra email_array <<< "$EMAILS"

# Starting Script
echo -e "\n*********************************************\nProcess started: $(date)\n*********************************************\n"

# Ensure the number of inputs matches
if [[ ${#user_array[@]} -ne ${#name_array[@]} || ${#user_array[@]} -ne ${#email_array[@]} ]]; then
	echo -e "[Error]: Number of inputs do not match between -> USER_NAME - NAME - EMAIL. \n"
    # Ending Script
    echo -e "\n*******************************************\nProcess ended: $(date)\n*******************************************\n"
	exit 1 
fi

for i in "${!user_array[@]}"; do
	username="${user_array[$i]}"
	name="${name_array[$i]}"
	email="${email_array[$i]}"

    for attempt in {1..3}; do
        mail -a "/c1/c1_app/jenkins/workspace/Unix_User_Creation/sshkeys_storage/$username/id_rsa" \
        -s "Client1 - Unix Authentication Username: $username" \
        "$email" List-GLB-Client1-SV-ES@company.com <<EOF
Hi ${name},

Access has been granted for the requested environment(s): ${envs}.

Username: ${username}
Authentication Method: RSA private key
SV Password: <password>

You can now configure your RSA private key on your SSH client. Please refer to the following technical note for detailed instructions:
https://wiki.company.com/display/DOCS/SSH+key+authentication+on+Linux+Servers

For detailed information about Client1 environments, visit:
https://wiki.company.com/display/DOCS/SV+Environments
Document: Environments Listing.xlsx (right-click the link and choose "Save link as..." to download)

This is an automated message. If you have any questions or need assistance, please contact the PE team at:
List-GLB-Client1-SV-ES@company.com
EOF

        sleep 30
        
    done

echo -e "\n SSH Private key has been sent to ${email} for username:${username}.\n" 

done

# Ending Script
echo -e "\n*******************************************\nProcess ended: $(date)\n*******************************************\n"


# Disable debug mode
#set +x

#v1.0 29-may-2025 