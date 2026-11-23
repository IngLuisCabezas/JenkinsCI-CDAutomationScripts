#!/bin/bash

#Enable debug mode
set -x

#Environment variables
export TZ="UTC"
sv_user=$(whoami)
output_file="$NODE_NAME.log"

# Redirect output (stdout) and errors (stderr)
exec > "$output_file" 2>/dev/null

#Starting Script
echo    "---------------------------------------------"
echo    "Process started: $(date) $(TZ)"
echo -e "---------------------------------------------\n"
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
        
        #check release installation
      	output=\$(ps -fu ${ENVIRONMENT_NAME} | grep install | grep -v ssh  |  grep -v grep | wc -l )  
		if [ \${output} -gt "0" ]; then   
            echo -e \"*******************************************************************************************************\"
            echo -e \"*******************************************************************************************************\"
            echo -e \"*******************************************************************************************************\"
        	echo -e  "[ALERT]: RELEASE INSTALLATION IS IN PROGRESS ${NODE_NAME^^} SV$((i+1)):${instances_array[$i]} "
            echo -e \"*******************************************************************************************************\"
            echo -e \"*******************************************************************************************************\"
        	echo -e \"*******************************************************************************************************\\n\"
			exit 1
        fi 

		#sv1
        if [ $i -eq 0 ]; then        

			#sv_status -cluster
            echo -e \"\\n\" 
        	echo -e \"****************************************************************\"
        	echo -e  "SECTION[SV$((i+1))]: sv_status -cluster"
        	echo -e \"****************************************************************\\n\"      
      	  	
            output=\$(sv_status -cluster 2>&1 | tail -n +2)  
            alert_printed=false
			while read -r line; do
    		    # Alert conditions
                if [ \"\$alert_printed\" = false ] && (
        		[ \"\$line\" = 'Server is in an unknown state. Tuxedo is running, but no BBL process exists on the server.' ] ||
           		[ \"\$line\" = 'CB Server NOT RUNNING.' ] ||
           		[ \"\$line\" = 'NO server running' ] ||
           		[ \"\$line\" = 'Server Common Processes RUNNING' ] ||
           		[ \"\$line\" = 'Server is STARTING UP.' ] ||
           		[ \"\$line\" = 'Server is SHUTTING DOWN.' ] ||
           		[ \"\$line\" = 'Unknown.' ] );then
            		echo "[ALERT] Env:${NODE_NAME^^} CB ERROR:[\$line]"
                	alert_printed=true
                fi     
			done <<< "\$output"
            
            output=\$(sv_status -cluster | grep -e 'PE Server')
     		while read -r line; do
				Active=\$(echo "\$line" | awk '{print \$7}')
            	Standby=\$(echo "\$line" | awk '{print \$9}')
            	RESTRICTED=\$(echo "\$line" | awk '{print \$5}')
           		if [ \"\$line\" = 'PE Server NOT RUNNING.' ]; then
            	   	echo "[ALERT] Env:${NODE_NAME^^} PE Error:[\$line]"
    			fi   
            	if [ \"\$Active\" = 'Active' ] || [ \"\$Standby\" = 'Standby' ] ; then
               	    echo "[INFO] Env:${NODE_NAME^^}:[\$line]"
            	fi
            	if [ \"\$RESTRICTED\" = 'RESTRICTED' ]; then
                	echo "[WARNING] Env:${NODE_NAME^^}:[\$line]"
            	fi
		    done <<< "\$output"
            
            sv_status -cluster 2>&1 | tail -n +2
            
            #HA 
            HA=\$(env | grep 'HA_ACTIVE=1' | wc -l)
			if [ \${HA} -eq "1" ]; then
        	    echo -e \"****************************************************************\"
        		echo -e  "SECTION[SV$((i+1))]: sv_ha_ctl cluster_status"
        		echo -e \"****************************************************************\\n\"
 			
                output=\$(sv_ha_ctl cluster_status 2>&1 | grep 'No inactive resources' | wc -l)
		    	if [ \${output} -eq "1" ]; then
			    	echo "[INFO] Env:${NODE_NAME^^} HA:No inactive resources"
				else
			 	    echo "[ALERT] Env:${NODE_NAME^^} HA ERROR Found" 
    			fi  
                
                echo -e \"\\n\" 
				sv_ha_ctl cluster_status 2>&1 | grep '* Node'
                echo -e \"\\n\" 
			 else
            	echo -e \"****************************************************************\"
        		echo -e  "SECTION[SV$((i+1))]: HA is Not Active in this env: ${NODE_NAME^^} "
        		echo -e \"****************************************************************\\n\"
    		fi
            
       fi
       
       #sv_status
       echo -e \"****************************************************************\"
       echo -e  "SECTION[SV$((i+1))]: sv_status env: ${NODE_NAME^^} SV$((i+1)):${instances_array[$i]} "
       echo -e \"****************************************************************\"     

       output=\$(svstatus 2>&1)
       while read -r line; do
          error=\$(echo "\$line" | awk '{print \$1}' | cut -c1-2)
          if [ \"\$error\" = '<E' ] || [ \"\$line\" = '<W' ]; then
             echo "[ALERT] Env:${NODE_NAME^^} SV$((i+1)):${instances_array[$i]} svstatus ERROR:[\$line]"
    	  fi   
	   done <<< "\$output"
       echo -e \"\\n\" 
	   svstatus 2>&1
       echo -e \"\\n\" 
	"                   
done

# mail

# Disable debug mode
set +x

echo    "-------------------------------------------"
echo    "Process ended: $(date) $(TZ)"
echo -e "-------------------------------------------\n"
#v1 pre/post check list.

