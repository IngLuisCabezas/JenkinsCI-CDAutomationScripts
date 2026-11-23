#!/bin/bash

#Enable debug mode
#set -x

#Environment variables
export TZ="UTC"
sv_user=$(whoami)
output_file="$NODE_NAME.txt"

# Artifact
#exec > $NODE_NAME.txt 2>&1
exec > $NODE_NAME.txt 2>/dev/null
#exec 2>/dev/null

#Starting Script
echo -e "*********************************************\nProcess started: $(date) $(TZ) \n*********************************************\n" 
echo -e "Singleview General Status\n" 
echo -e "Environment: ${NODE_NAME^^}\n" 
echo -e "[ALERT]: Review required - please investigate and remediate."
echo -e "[WARNING]: Verification needed - please confirm accuracy."
echo -e "[INFO]: Output validated - results meet expected criteria.\n"

#Go through every single instance
instances_array=($(da_dump InstanceStatus | sed -n 1!p | awk -F '"*,"*' '{print $24}'))
for ((i=0; i<${#instances_array[@]}; i++)); do
	ssh $sv_user@${instances_array[$i]} "
    	#!/bin/bash
        #Instance variables
        source ~/.profile > /dev/null
        
        #sv1
        if [ $i -eq 0 ]; then

        ########################SV1 Code ############################
		echo -e \"-----\\nsv_status -cluster\\n\" 
        output=\$(sv_status -cluster 2>&1 | tail -n +2)  
		while read -r line; do
       	 	if [ \"\$line\" = 'Server is in an unknown state. Tuxedo is running, but no BBL process exists on the server.' ] || [ \"\$line\" = 'CB Server NOT RUNNING.' ] || [ \"\$line\" = 'NO server running' ] || [ \"\$line\" = 'Server Common Processes RUNNING' ] || [ \"\$line\" = 'Server is STARTING UP.' ] || [ \"\$line\" = 'Server is SHUTTING DOWN.' ] || [ \"\$line\" = 'Unknown.' ]; then
            echo "9- [ALERT] CB - please check: SV Instance [\$line]"
            echo -e \"\\n\" 
    		fi     
done <<< "\$output"
		output=\$(sv_status -cluster | grep -e 'PE Server')
        while read -r line; do
			Active=\$(echo "\$line" | awk '{print \$7}')
            Standby=\$(echo "\$line" | awk '{print \$9}')
            RESTRICTED=\$(echo "\$line" | awk '{print \$5}')
            if [ \"\$line\" = 'PE Server NOT RUNNING.' ]; then
               echo "9- [ALERT] PE - please check: SV Instance [\$line]"
    		fi   
            if [ \"\$Active\" = 'Active' ]; then
               echo "\$line"
               a=1
            fi
            if [ \"\$Standby\" = 'Standby' ]; then
			   echo "\$line"
               b=1
            fi
            if [ \"\$RESTRICTED\" = 'RESTRICTED' ]; then
               echo -e \"\\n\" 
               echo "9- [ALERT] PE - please check: \$line "
                            fi
done <<< "\$output"   	  
            output=\$(sv_status -cluster | grep -e 'PE Server' | wc -l)
			if [ \${output} -ge 1 ]; then
           		if [ \${a} -eq "1" ] && [ \${b} -eq "1" ]; then
                    echo -e \"\\n[INFO] ${NODE_NAME^^} PE Active/Standby Mode OK \\n\" 
            	else
        	   		echo "[WARNING] Check PE is not running in Active/Standby Mode."
    			fi
            fi    
            #sv_status -cluster 2>&1
        #############################################################

	    fi    
        echo -e \"\\n\"		
        echo -e \"-----\\n SV$((i+1)): ${instances_array[$i]} \\n\"  
"                 
done

#Send Email

# Disable debug mode
#set +x

echo -e "*******************************************\nProcess ended: $(date) $(TZ) \n*******************************************\n" 

  