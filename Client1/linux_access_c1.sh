#!/bin/bash

# Environment variables
export TZ="UTC"
export time_max=30
export envs="envs:"
#export defaultpasswd = "<password>" 

# array
IFS=',' read -ra user_array <<< "$USER_NAMES"
IFS=',' read -ra name_array <<< "$NAMES"
IFS=',' read -ra email_array <<< "$EMAILS"

# Function
create_user_and_copy_ssh_key() {

local server=("$1")  
local username="$2"       
local name="$3"           

   timeout "$time_max" ssh -T "corp@$server" <<EOF

# Check if the  public ssh key was copied to destinetion server
if [ -e "/home/corp/id_rsa.pub" ]; then

   if id "$username" &>/dev/null; then
   
            echo -e "\n[INFO]: User $username already exits on $server \${HOSTNAME}.\n"
			
			# Set password using chpasswd
			echo "<password>" | sudo passwd --stdin $username
			# Unlock user if locked
			sudo usermod -U $username
			# Prevent password change prompt on first login
			sudo chage -d "$(date +%Y-%m-%d)" $username
			# Optional: Disable password expiration
			sudo chage -M 99999 -I -1 -E -1 $username
            
			# Set permissions to allow copying the id_rsa.pub file
			sudo chmod 777 /home/"$username" && echo "[INFO]:Permissions changed" || { echo "[ALERT]: Directory /home/$username does not exit"; exit 0; }
            #sudo chmod 777 /home/$username/
            sudo mkdir /home/$username/.ssh
            sudo chmod 777 /home/$username/.ssh
            sudo touch /home/$username/.ssh/authorized_keys
            sudo touch /home/$username/.ssh/id_rsa
            sudo chmod 777 /home/$username/.ssh/authorized_keys
            sudo chmod 777 /home/$username/.ssh/id_rsa
			
        else
            # Create the user with a default password on the target server
            echo -e "\n[INFO]: Create user $username on $server \${HOSTNAME}.\n"
            
			sudo useradd -g ${USER_ROL} -c "${name} CORP" -s /bin/ksh -d /home/${username} -m -p $(echo <password> | openssl passwd -1 -stdin) ${username}
            # Unlock user if locked
			sudo usermod -U $username
			# Prevent password change prompt on first login
			sudo chage -d "$(date +%Y-%m-%d)" $username
			# Optional: Disable password expiration
			sudo chage -M 99999 -I -1 -E -1 $username

            # Set permissions to allow copying the id_rsa.pub file
			sudo chmod 777 /home/"$username" && echo "[INFO]:Permissions changed" || { echo "[ALERT]: Directory /home/$username does not exit"; exit 0; }
            #sudo chmod 777 /home/$username/
            sudo mkdir /home/$username/.ssh
            sudo chmod 777 /home/$username/.ssh
            sudo touch /home/$username/.ssh/authorized_keys
            sudo touch /home/$username/.ssh/id_rsa
            sudo chmod 777 /home/$username/.ssh/authorized_keys
            sudo chmod 777 /home/$username/.ssh/id_rsa

        fi
		
		    #truncate --size 0 /home/$username/.ssh/authorized_keys
			sudo cat "/home/corp/id_rsa.pub" >> "/home/$username/.ssh/authorized_keys"
            sudo cat "/home/corp/id_rsa" >> "/home/$username/.ssh/id_rsa"
			
			echo -e "\n[INFO]: Public ssh key has been updated to /home/$username/.ssh/authorized_keys file.\n"
			
			# Set right permissions to allow ssh key authentication from the remote server
			sudo chown -R $username:${USER_ROL} "/home/$username/.ssh"
			sudo chmod 700 "/home/$username/"
			sudo chmod 700 "/home/$username/.ssh"
	    	sudo chmod 600 "/home/$username/.ssh/authorized_keys"
			sudo chmod 600 "/home/$username/.ssh/id_rsa"
			sudo mv /home/corp/id_rsa.pub /home/corp/id_rsa.pub.latest
		    sudo mv /home/corp/id_rsa /home/corp/id_rsa.latest
             
			 echo -e "\n[INFO]: Right Permissions SET to /home/$username \n"
else
	echo -e "\n[ALERT]: SSH file for the username ${name} in /home/corp/id_rsa.pub does not exist on $server ${HOSTNAME}.\n NO UPDATED, WORKAROUND: TEST SSH CONNECTION"
fi

EOF

}

#Starting Script
echo -e "\n*********************************************\nProcess started: $(date)\n*********************************************\n"

# Check the value of the boolean variable
if [ "$DEV_HUB" = true ] || [ "$DEV_OCS" = true ] || [ "$BLD_HUB" = true ] || [ "$TST1_HUB" = true ] || [ "$TST1_OCS" = true ] || [ "$TST2_HUB" = true ] || [ "$TST2_OCS" = true ] || [ "$HAR_HUB" = true ] || [ "$HAR_OCS_KY" = true ] || [ "$HAR_OCS_BB" = true ] || [ "$HAR_OCS_ANT" = true ] || [ "$REF_HUB" = true ] || [ "$TRN_HUB" = true ] || [ "$SIT_HUB" = true ] || [ "$SIT_OCS_KY" = true ] || [ "$SIT_OCS_BB" = true ] || [ "$SIT_OCS_ANT" = true ] || [ "$UAT_HUB" = true ] || [ "$UAT_OCS_KY" = true ] || [ "$UAT_OCS_BB" = true ] || [ "$UAT_OCS_ANT" = true ] || [ "$PRD_HUB" = true ] || [ "$PRD_OCS_KY" = true ] || [ "$PRD_OCS_BB" = true ] || [ "$PRD_OCS_ANT" = true ] || [ "$PREPRD_HUB" = true ] || [ "$PREPRD_OCS_KY" = true ] || [ "$PREPRD_OCS_BB" = true ] || [ "$PREPRD_OCS_ANT" = true ] || [ "$MNT_HUB" = true ] || [ "$MNT_OCS_BB" = true ] || [ "$MNT_OCS_ANT" = true ] || [ "$MNT_OCS_KY" = true ] || [ "$DEV_MNT" = true ] || [ "$DEV_MNT_OCS" = true ] || [ "$BLD_MNT__TST_MNT" = true ] || [ "$TST_MNT_OCS" = true ] || [ "$REF2_HUB" = true ] || [ "$REF2_OCS" = true ] || [ "$HAR2_HUB" = true ] || [ "$HAR2_OCS_KY" = true ] || [ "$HAR2_OCS_BB" = true ] || [ "$HAR2_OCS_ANT" = true ] || [ "$TST3_HUB" = true ] || [ "$TST3_OCS" = true ] || [ "$PRF_HUB" = true ] || [ "$PRF_OCS" = true ] || [ "$TRN_OCS" = true ] || [ "$TST4_HUB" = true ] || [ "$TST4_OCS" = true ] || [ "$REF3_HUB" = true ] || [ "$REF3_OCS" = true ]; then
	echo -e "[INFO]: At least one environment has been selected. \n" 
else
	echo -e "[ALERT]: Error, Select at least one environment. \n" 
	exit 1
fi

# Ensure the number of inputs matches
if [[ ${#user_array[@]} -ne ${#name_array[@]} || ${#user_array[@]} -ne ${#email_array[@]} ]]; then
	echo -e "[ALERT]: Error,  Number of inputs does not match between -> USER_NAME - NAME - EMAIL. \n"
	exit 1 
fi

for i in "${!user_array[@]}"; do
	username="${user_array[$i]}"
	name="${name_array[$i]}"
	email="${email_array[$i]}"
    envs="envs:" 
	# Generate SSH key pair on the local machine
	if [ -f "sshkeys_storage/$username/id_rsa" ]; then
		# SSH key pair exists
		echo -e "\n[INFO]: SSH key pair already exists for ${username}.\n"
	else
		# SSH key does not exist, need to be created
		mkdir "sshkeys_storage/$username"
		ssh-keygen -t rsa -b 4096 -f "sshkeys_storage/$username/id_rsa" -N "" -C "$username"
		echo -e  "\n[INFO]: SSH key pair for ${username} has been created. \n"
	fi
  

	process_env() {
    	local env_var_name="$1"
    	local server_list="$2"
    	local env_display_name="$env_var_name"

    	if [ "${!env_var_name}" = true ]; then
        	envs="${envs} $env_display_name "
        	echo -e "\n[INFO]: $env_display_name env has been selected. \n"
        	IFS=',' read -ra server_array <<< "$server_list"

        	for server in "${server_array[@]}"; do
            	scp "sshkeys_storage/$username/id_rsa.pub" "corp@$server:/home/corp/."
            	scp "sshkeys_storage/$username/id_rsa" "corp@$server:/home/corp/."
            	echo -e "\n[INFO]: Copied public ssh key for $username to $server. \n"

            	create_user_and_copy_ssh_key "$server" "$username" "$name"
        	done
    	fi
	}

	# Call the function for each environment
	# process_env DEV_HUB "172.x.x.x"
	process_env DEV_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env DEV_OCS "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
	process_env DEV_MNT "xx.19.52.xx"
	process_env DEV_MNT_OCS "xx.19.109.xx"	
	process_env BLD_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env BLD_MNT__TST_MNT "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env TST_MNT_OCS "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
	process_env TST1_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env TST1_OCS "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
	process_env TST2_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env TST2_OCS "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"	
	process_env TST3_HUB "xx.19.52.xx"
	process_env TST3_OCS  "xx.19.109.xx"
	process_env TST4_HUB "xx.19.52.xx"
	process_env TST4_OCS "xx.19.109.xx"
	process_env TRN_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env TRN_OCS "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env REF_HUB "xx.19.52.xx"
	process_env REF2_HUB "xx.19.52.xx"
	process_env REF2_OCS "xx.19.53.xx"
	process_env REF3_HUB "xx.19.47.xx"
	process_env REF3_OCS "xx.19.47.xx"
	process_env HAR_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env HAR_OCS_KY "xx.19.111.xx,xx.19.111.xx,xx.19.111.xx"
	process_env HAR_OCS_BB "xx.19.112.xx,xx.19.112.xx,xx.19.112.xx"
	process_env HAR_OCS_ANT "xx.19.114.xx,xx.19.114.xx,xx.19.114.xx"
	process_env HAR2_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env HAR2_OCS_KY "xx.19.111.xx,xx.19.111.xx,xx.19.111.xx"
	process_env HAR2_OCS_BB "xx.19.112.xx,xx.19.112.xx,xx.19.112.xx"
	process_env HAR2_OCS_ANT "xx.19.114.xx,xx.19.114.xx,xx.19.114.xx"
	process_env SIT_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env SIT_OCS_KY "xx.18.141.xx,xx.18.141.xx,xx.18.141.xx"
	process_env SIT_OCS_BB "xx.18.38.xx,xx.18.38.xx,xx.18.38.xx"
	process_env	SIT_OCS_ANT "xx.21.158.xx,xx.21.158.xx,xx.21.158.xx"
	process_env UAT_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env UAT_OCS_KY "xx.18.141.xx,xx.18.141.xx,xx.18.141.xx"
	process_env UAT_OCS_BB "xx.18.38.xx,xx.18.38.xx,xx.18.38.xx"
	process_env UAT_OCS_ANT "xx.21.158.xx,xx.21.158.xx,xx.21.158.xx"
	process_env MNT_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env MNT_OCS_KY "xx.19.115.xx,xx.19.115.xx,xx.19.115.xx"
	process_env MNT_OCS_BB "xx.19.124.xx,xx.19.124.xx,xx.19.124.xx"
	process_env MNT_OCS_ANT "xx.19.4.xx,xx.19.4.xx,xx.19.4.xx"
	process_env PRF_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env PRF_OCS "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
	process_env PREPRD_HUB "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
	process_env PREPRD_OCS_KY "xx.19.115.xx,xx.19.115.xx,xx.19.115.xx"
	process_env PREPRD_OCS_BB "xx.19.124.xx,xx.19.124.xx,xx.19.124.xx"
	process_env PREPRD_OCS_ANT "xx.19.4.xx,xx.19.4.xx,xx.19.4.xx"
	process_env PRD_HUB "xx.19.53.xx,xx.19.53.xx,xx.19.53.xx,xx.19.53.xx,xx.19.53.xx"
	process_env PRD_OCS_KY "xx.19.115.xx,xx.19.115.xx,xx.19.115.xx"
	process_env PRD_OCS_BB "xx.19.124.xx,xx.19.124.xx,xx.19.124.xx"
	process_env PRD_OCS_ANT "xx.19.4.xx,xx.19.4.xx,xx.19.4.xx"

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

echo -e "\n[INFO]: SSH Private key has been sent to ${email} for username:${username}.\n"

done

echo -e "\n--------------------------------------------------\n Ending at $(date) $(TZ). \n--------------------------------------------------\n"


### added echo "[ALERT]: Directory /home/$username does not exit"