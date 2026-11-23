#!/bin/bash

# Enable debug mode
set -x

# Environment variables
sv_user=$(whoami)

export TZ=UTC
srvgrp="OCSHUB"
srvgrp_id=132
serverid_array="1300 1350 1200 1250 1400 1450 1500 1550 1600 1650 1700 1750"

echo -e "--------------------------------------------------\n Starting at $(date) $(TZ) \n--------------------------------------------------\n" >  $NODE_NAME.txt

echo -e "\n \n" >>  $NODE_NAME.txt
echo "SV HTTP2 ADAPTORS STATUS: $NODE_NAME $sv_user" >>  $NODE_NAME.txt
echo -e "\n \n" >>  $NODE_NAME.txt

instances_array=($(da_dump InstanceStatus | sed -n 1!p | awk -F '"*,"*' '{print $24}'))

for ((i=0; i<${#instances_array[@]}; i++)); do

    ssh -q "$sv_user@${instances_array[$i]}" <<EOF >> $NODE_NAME.txt
	
        echo -e "\nHTTP2 ADAPTORS STATUS SV$((i+1)): ${instances_array[$i]} \n"
        
        export serverid_array="$serverid_array"
        for id in \$serverid_array; do  # Use \$ to reference the remote variable
        	
            #echo -e "\nServer ID: \$id"
       		#grep "SRVGRP=$srvgrp SRVID=\$id" /c1/$sv_user/data/server/config/ubbconfig.tpl
            #grep "SRVGRP=$srvgrp SRVID=\$id" /c1/$sv_user/data/server/config/ubbconfig.tpl | wc -l
            count=\$(grep "SRVGRP=$srvgrp SRVID=\$id" /c1/$sv_user/data/server/config/ubbconfig.tpl | wc -l)
            #echo -e "Count: \$count"
      
        	if [ \${count} -eq 1 ]; then
          
            	#ps -fu $sv_user | grep " -g $srvgrp_id -i \$id"  
                count2=\$(ps -fu $sv_user | grep " -g $srvgrp_id -i \$id" | wc -l)
        		#echo -e "Count2: \$count2"
                
                if [ \${count2} -eq 1 ]; then
                   echo -e "Starting adaptor -g $srvgrp -i \$id"
                   tmboot -g $srvgrp -i \$id
                fi
               
            fi
        done
        
       echo -e "\nADAPTERES STATUS SV$((i+1))"
       tuxservices -g $srvgrp
       echo -e "ADAPTERES RUNNING SV$((i+1))"
       tuxservices -g $srvgrp |  tail -n +6 | wc -l
       echo -e "\n \n"    
        
EOF

done

# Create and write a footer with the ending date and time
echo -e "--------------------------------------------------\n Ending at $(date) $(TZ). \n--------------------------------------------------\n" >> $NODE_NAME.txt

# Disable debug mode
set +x
