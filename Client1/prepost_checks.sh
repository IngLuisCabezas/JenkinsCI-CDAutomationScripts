#!/bin/bash

#Enable debug mode
set -x

#Environment variables
export TZ="UTC"
sv_user=$(whoami)

#Starting Script
echo -e "*********************************************\nProcess started: $(date) $(TZ) \n*********************************************\n" >  $NODE_NAME.txt
echo -e "SINGLEVIEW COMPONENTS CHECKLIST\nENVIRONMENT:$NODE_NAME\n" >>  $NODE_NAME.txt
echo -e "NOTE:\n[ALERT]: The output result must be checked and resolved.\n[WARNING]: The output result must be validated.\n[COMMENT]: The output result is as expected.\n" >>  $NODE_NAME.txt
#Go through every single instance
instances_array=($(da_dump InstanceStatus | sed -n 1!p | awk -F '"*,"*' '{print $24}'))
for ((i=0; i<${#instances_array[@]}; i++)); do
	ssh $sv_user@${instances_array[$i]} "
    	#!/bin/bash
        #Instance variables
        source ~/.profile > /dev/null
        timezone_names='v\$timezone_names'
        #sv1
        if [ $i -eq 0 ]; then
        echo -e "-----"
        output=\$( relinfo 2>&1  |  head -n 3 | tail -n +3 | awk '{print \$3}')
        echo -e "i- [COMMENT] Currently installed release: \$output"
        echo -e "-----"
		echo -e \"-----\\nSECTION 1:Check clock to avoid PE restrict mode issue:\\n\"  
        app_date=\$(date +'%d-%m-%Y %H:%M:%S') 
        db_date=\$(sqlplus -S \$ATADBACONNECT <<SQL
SET PAGESIZE 0
SET FEEDBACK OFF
SET LINESIZE 32000
SET TAB OFF
SET TIMING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS') FROM DUAL;
EXIT
SQL
)                          
		app_tz=\$(echo "\$TZ") 
		db_tz=\$(sqlplus -S \$ATADBACONNECT <<SQL
SET PAGESIZE 0
SET FEEDBACK OFF
SET LINESIZE 32000
SET TAB OFF
SET TIMING OFF
SELECT DBTIMEZONE FROM DUAL;
EXIT
SQL
)
		 app_d2=\$(echo "\$app_date" | cut -c 1-16)
		 db_d2=\$(echo "\$db_date" | cut -c 1-16)
         if [ \"\$app_tz\" = \"\$db_tz\" ]; then
      		echo "1- [COMMENT] TZ on App and DB are ok: \$app_tz"
        else 
            echo "1- [ALERT]  TZ mismatch. Please Check. App TZ: \$app_tz - DB TZ:\$db_tz"
        fi
        if [ \"\$app_d2\" = \"\$db_d2\" ]; then
            echo "1- [COMMENT] SYSDATE on App and DB are ok: \$app_date"
        else 
            echo "1- [ALERT]  SYSDATE mismatch. Please Check. App SYSDATE: \$app_d2 - DB SYSDATE:\$db_d2"
        fi
        echo -e \"-----\\nSECTION 2:dbsync -review result:\\n\"  
        dbsr=\$(dbsync -review 2>&1 | tail -n 1)
        if [ \"\$dbsr\" = '<M06145> Verification complete.' ]; then
           echo "2- [COMMENT] dbsync -review is ok:	\$dbsr "
           #dbsync -review 2>&1 | tail -n 10
        else
           echo "2- [ALERT] Check:"
           dbsync -review 2>&1 | tail -n 10
        fi
        echo -e \"-----\\nSECTION 3:Check no missing entities, query result:\\n\"
        db_me=\$(sqlplus -S \$ATADBACONNECT <<SQL 
SET PAGESIZE 0
SET TIMING OFF 
SET LINESIZE 32000
SET TAB OFF
select variable_defn_name from variable_defn_history where variable_defn_id in (select variable_defn_id from derived_attribute where derived_attribute_id not in (select derived_attribute_id from derived_attribute_history));
SQL
)                         
        db_me2=\$(echo "\$db_me")
        if [ \"\$db_me2\" = 'no rows selected' ]; then
			echo "3- [COMMENT]  No missing entities: \$db_me2"
		else
		echo "3- [ALERT] Check, Missing Entities:"
        echo "\$db_me"
		fi
        echo -e \"-----\\nSECTION 4:cfg SFM INSTANCE status:\\n\"
        output=\$(cfg SFM INSTANCE -l | tail -n +2)
        while read -r line; do
        sfm=\$(echo "\$line" | awk '{print \$2}' | cut -c4)
        sv=\$(echo "\$line" | awk '{print \$3}' | cut -c3)      
        if [ \"\$sfm\" = \"\$sv\" ]; then
			echo "4- [COMMENT] Match: SFM[\$sfm] = SV[\$sv]"
    	else
			echo "4- [WARNING] SFM mismatch please check: SFM[\$sfm] = SV[\$sv]"
		fi              
done <<< "\$output"
        echo -e \"-----\\nSECTION 5:cfg SFM ENABLED status:\\n\"
        output=\$(cfg SFM ENABLED -l 2>&1 | tail -n +2)
	    while read -r line; do
        sfme=\$(echo "\$line" | awk '{print \$3}' )
		sfm=\$(echo "\$line" | awk '{print \$2}')                            
        if [ \"\$sfme\" = "1" ]; then
           echo "5- [COMMENT] \$sfm = \$sfme"
    	else
           echo "5- [WARNING] SFM DISABLED: \$sfm = \$sfme"
        fi              
done <<< "\$output"
        echo -e \"-----\\nSECTION 6:cfg SFM QUEUE_MAXIMUM value:\\n\"
        output=\$(cfg SFM QUEUE_MAXIMUM -l 2>&1 | tail -n +2)
		while read -r line; do
         sfmqm=\$(echo "\$line" | awk '{print \$3}' )
		 sfm=\$(echo "\$line" | awk '{print \$2}')                            
         if [ \${sfmqm} -ge "10000" ]; then
        	echo "6- [COMMENT] \$sfm = \$sfmqm"
    	 else
        	echo "6- [ALERT] \$sfm QUEUE_MAXIMUM value  needs to be set 10000. \$sfm = \$sfmqm"
         fi              
done <<< "\$output"
        echo -e \"-----\\nSECTION 7:cfg STD INSTANCE status:\\n\"
        output=\$(cfg STD INSTANCE -l 2>&1 | tail -n +2)
		while read -r line; do
			std=\$(echo "\$line" | awk '{print \$2}' | cut -c4)
            sv=\$(echo "\$line" | awk '{print \$3}' | cut -c3)
            if [ \"\$std\" = \"\$sv\" ]; then
				echo "7- [COMMENT] Match: STD[\$std] = SV[\$sv]"
    		else
        	    echo "7- [ALERT] STD mismatch please check: STD[\$std] = SV[\$sv]"
    		fi              
done <<< "\$output"
		echo -e \"-----\\nSECTION 8:cfg TLM INSTANCE status:\\n\" 
        output=\$(cfg TLM INSTANCE -l 2>&1 | tail -n +2)
		while read -r line; do
			tlm=\$(echo "\$line" | awk '{print \$2}' | cut -c4)
			sv=\$(echo "\$line" | awk '{print \$3}' | cut -c3)
			if [ \"\$tlm\" = \"\$sv\" ]; then
				echo "8- [COMMENT] Match: TLM[\$tlm] = SV[\$sv]"
			else
				echo "8- [ALERT] TLM mismatch please check: TLM[\$tlm] = SV[\$sv]"
			fi              
done <<< "\$output"
		
        echo -e \"-----\\nSECTION 9:cfg SVSC INSTANCE LIST\" 
        cfg SVSC INSTANCE -l 2>&1 | tail -n +2 
		echo "SECTION 9: cfg SVSC ENABLED LIST"
		cfg SVSC ENABLED -l 2>&1 | tail -n +2
        
		echo -e \"-----\\nSECTION 9:STATUS CLUSTER:\\n\" 
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
               		echo -e \"\\n\"
               		echo "9- [COMMENT] PE Active/Standby Mode OK "
                    echo -e \"\\n\"
            	else
                    echo -e \"\\n\"
        	   		echo "9- [WARNING] Check PE is not running in Active/Standby Mode."
               		echo -e \"\\n\"
    			fi
            fi    
            sv_status -cluster 2>&1
        prd=\$(whoami | grep 'prd1b' | wc -l)
		pocs=\$(whoami | grep 'pocs1b'  | wc -l)
		if [ \${prd} -eq "1" ] || [ \${pocs} -eq "1" ]; then
            echo -e \"-----\\nSECTION 9.1:HA is Enabled: ${instances_array[$i]} \\n\"
 			output=\$(sv_ha_ctl cluster_status 2>&1 | grep 'No inactive resources' | wc -l)
		    if [ \${output} -eq "1" ]; then
				echo "9- [COMMENT] - Inactive Resources: No inactive resources"
				echo -e \"\\n\" 
			else
				echo "9- [ALERT] - Please check  sv_ha_ctl cluster_status "
				echo -e \"\\n\" 
    		fi 
			echo "SV_HA_CTL CLUSTER_STATUS"
            echo -e \"\\n\" 
			sv_ha_ctl cluster_status
            
		else
          echo -e \"-----\\nSECTION 9.1:HA is not Enabled for this env.\\n\"
    	fi
	fi    
        echo -e \"\\n\"
        echo -e \"\\n\"		
        echo -e \"-----\\nSECTION 10:SAR INSTANCE SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$(sar 2>&1 | tail -2 | head -n 1 | awk '{print \$9}' | cut -c1-2)
        if [ \${output} -lt 50 ]; then
           echo "10- [ALERT] \%idle is less than 50\% = [\$output]\% "
           echo -e \"\\n\"
           sar 2>&1 | head -n 3 | tail -1; sar 2>&1 | tail -2
         else
           echo "10- [COMMENT] \%idle is OK = [\$output]\% "
           echo -e \"\\n\"
           sar 2>&1 | head -n 3 | tail -1; sar 2>&1 | tail -2
        fi   
        echo -e \"-----\\nSECTION 11:C1 DISK SPACE INSTANCE SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$(df -h /c1 2>&1 | tail -1 | awk '{print substr(\$5, 1, length(\$5)-1)}')
        if [ \${output} -ge 90 ]; then
           echo "11- [ALERT] c1 disk space \%used  = [\$output]\% "
           echo -e \"\\n\"
           df -h /c1 2>&1
         else
           echo "11- [COMMENT] c1 disk space \%used  is ok = [\$output]\%  "
           echo -e \"\\n\"
           df -h /c1 2>&1
        fi       
        echo -e \"-----\\nSECTION 12: SVSTATUS SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$(svstatus 2>&1)
        svstatus 2>&1
        echo -e \"\\n\" 
        while read -r line; do
           error=\$(echo "\$line" | awk '{print \$1}' | cut -c1-2)
            if [ \"\$error\" = '<E' ] || [ \"\$line\" = '<W' ]; then
               echo "12- [ALERT] SV status: [\$line]"
    		fi   
done <<< "\$output"
        echo -e \"-----\\nSECTION 13: SFM SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$(ataprocs | grep sfm | wc -l)
        if [ \${output} -ge 1 ]; then
           echo "13- [COMMENT] SFM process is running "
           echo -e \"\\n\"
         else
           echo "13- [ALERT] SFM  process is not running "
           echo -e \"\\n\"
        fi       
        echo -e \"-----\\nSECTION 14: TLM SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$(ataprocs | grep tlm | wc -l)
        if [ \${output} -ge 1 ]; then
           echo "14- [COMMENT] TLM process is running "
           echo -e \"\\n\"
         else
           echo "14- [ALERT] TLM  process is not running "
           echo -e \"\\n\"
        fi   
        
        Active=\$(sv_status | grep -e 'PE Server' |  awk '{print \$7}')
 		if [ \"\$Active\" = 'Active' ]; then
			   #echo "\$Active"
               echo -e \"-----\\nSECTION 15: PE SV Instance processes that need to be running  SV$((i+1)): ${instances_array[$i]} \\n\"
               output=\$(ataprocs | grep perest | head -n 1 | wc -l)
        		if [ \${output} -ge 1 ]; then
          		 	echo "15- [COMMENT] PEREST process is running "
          			 echo -e \"\\n\"
         		else
       			    echo "15- [ALERT] PEREST process is not running, Please Check. "
         		    echo -e \"\\n\"
        		fi  
               output=\$(ataprocs | grep trewfe | head -n 1 | wc -l)
        		if [ \${output} -ge 1 ]; then
          		 	echo "15- [COMMENT] TREWFE process is running "
          			 echo -e \"\\n\"
         		else
       			    echo "15- [ALERT] TREWFE process is not running, Please Check. "
         		    echo -e \"\\n\"
        		fi      
               output=\$(ataprocs | grep trerest_in  | head -n 1 | wc -l)
        		if [ \${output} -ge 1 ]; then
          		 	echo "15- [COMMENT] TREREST_IN process is running "
          			 echo -e \"\\n\"
         		else
       			    echo "15- [ALERT] TREREST_IN process is not running, Please Check. "
         		    echo -e \"\\n\"
        		fi   
               output=\$(ataprocs | grep trerest_out | head -n 1 | wc -l)
        		if [ \${output} -ge 1 ]; then
          		 	echo "15- [COMMENT] TREREST_OUT process is running "
          			 echo -e \"\\n\"
         		else
       			    echo "15- [ALERT] TREREST_OUT process is not running, Please Check. "
         		    echo -e \"\\n\"
        		fi   
               output=\$(ataprocs | grep  tresoap | head -n 1 | wc -l)
        		if [ \${output} -ge 1 ]; then
          		 	echo "15- [COMMENT] TRESOAP process is running "
          			 echo -e \"\\n\"
         		else
       			    echo "15- [ALERT] TRESOAP process is not running, Please Check. "
         		    echo -e \"\\n\"
        		fi
		fi
        
        output=\$(cfg BAS 1 INSTANCE | cut -c3)
        in=$((i+1))
		if [ \"\$output\" = \"\$in\" ]; then
           echo -e \"-----\\nSECTION 16: BAS SV Instance proces that need to be running  SV$((i+1)): ${instances_array[$i]} \\n\"
			echo "BAS is in SV[\$output]"
            output=\$(ataprocs | grep bas | head -n 1 | wc -l)
        		if [ \${output} -ge 1 ]; then
          		 	echo "16- [COMMENT] BAS process is running "
          			 echo -e \"\\n\"
         		else
       			    echo "16- [ALERT] BAS process is not running, Please Check. "
         		    echo -e \"\\n\"
        		fi  
	    fi  
		echo -e \"-----\\nSECTION 17: H2CEA Adapter SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$(ataprocs | grep h2cea  | wc -l)
		case \${output} in
			0)
				echo "17- [ALERT] H2CEA Adapter is not running, Please Check. "
				;;
			1)
			
				echo "17- [COMMENT] One H2CEA Adapter is running, OK"
				;;
			*)
      
                echo "17- [WARNING] More than one H2CEA Adapter are running, please validate."
				;;
		esac 
        #nope=\$(cfg PEREST -l 2>&1 | grep '<E90000>' | wc -l)
		ocs=\$(whoami | grep 'ocs' | wc -l)
		if [ \${nope} -eq "1" ] || [ \${ocs} -eq "1" ]; then
            echo -e \"-----\\nSECTION 18: DECEA Adapters that need to be running in OCS env SV$((i+1)): ${instances_array[$i]} \\n\"
 			output=\$(ataprocs | grep dcea | awk '{print \$1, substr(\$2, 1, 4), \$3}' | grep dcea | wc -l)
				case \${output} in
					[0-4])
							echo "18- [ALERT] There are less than 5 DCEA Adapters up, Please Check."
							ataprocs | grep dcea | awk '{print \$1, substr(\$2, 1, 4), \$3}' | grep dcea
							;;
						5)
			
							echo "18- [COMMENT] There are 5 DCEA Adapters up, ok."
							ataprocs | grep dcea | awk '{print \$1, substr(\$2, 1, 4), \$3}' | grep dcea
							;;
						*)
							echo "18- [WARNING] There are more than 5 DCEA Adapters up, please validate."
                            ataprocs | grep dcea | awk '{print \$1, substr(\$2, 1, 4), \$3}' | grep dcea
							;;
							esac            
            echo -e \"\\n\"
            echo -e \"-----\\nSECTION 19: HTTP2 Adapters that need to be running in OCS env SV$((i+1)): ${instances_array[$i]} \\n\"
 			output=\$(tuxservices -g OCSHUB |  tail -n +6 | wc -l)
				case \${output} in
						0)
							echo "19- [ALERT] There is not any HTTP2 Adapter up, Please Check."
							tuxservices -g OCSHUB | tail -n +2 | head -n -2
                            echo -e \"\\n\"
                            echo -e "HTTP2 ADAPTERES RUNNING SV$((i+1))"
                            tuxservices -g OCSHUB |  tail -n +6 | wc -l                            
							;;
						1)
			
							echo "19- [COMMENT] There is one HTTP2 Adapter up, ok."
							tuxservices -g OCSHUB | tail -n +2 | head -n -2
                            echo -e \"\\n\"
                            echo -e "HTTP2 ADAPTERES RUNNING SV$((i+1))"
                            tuxservices -g OCSHUB |  tail -n +6 | wc -l                           
							;;
						*)
							echo "19- [WARNING] There are more than one HTTP2 Adapter up, please validate."
                            tuxservices -g OCSHUB | tail -n +2 | head -n -2
                            echo -e \"\\n\"
                            echo -e "HTTP2 ADAPTERES RUNNING SV$((i+1))"
                            tuxservices -g OCSHUB |  tail -n +6 | wc -l                            
							;;
							esac            
            echo -e \"\\n\"  			
		else 
           	 echo -e \"-----\\nSECTION 18: HTTP2 Adapters that need to be running in HUB env SV$((i+1)): ${instances_array[$i]} \\n\"
 			output=\$(tuxservices -g OCSHUB |  tail -n +6 | wc -l)
				case \${output} in
					[0-5])
							echo "18- [ALERT] There are less than six HTTP2 Adapters up, Please Check.."
							tuxservices -g OCSHUB | tail -n +2 | head -n -2
                            echo -e \"\\n\"
                            echo -e "HTTP2 ADAPTERES RUNNING SV$((i+1))"
                            tuxservices -g OCSHUB |  tail -n +6 | wc -l
							;;
						6)
			
							echo "18- [COMMENT] There are six HTTP2 Adapters up, ok."
							tuxservices -g OCSHUB | tail -n +2 | head -n -2
                            echo -e \"\\n\"
                            echo -e "HTTP2 ADAPTERES RUNNING SV$((i+1))"
                            tuxservices -g OCSHUB |  tail -n +6 | wc -l                            
							;;
						*)
							echo "18- [WARNING] There are more than six HTTP2 Adapters up, please validate."
                            tuxservices -g OCSHUB | tail -n +2 | head -n -2
                            echo -e \"\\n\"
                            echo -e "HTTP2 ADAPTERES RUNNING SV$((i+1))"
                            tuxservices -g OCSHUB |  tail -n +6 | wc -l                            
							;;
							esac            
            echo -e \"\\n\"  	
    	fi
      
      echo -e \"-----\\nSECTION 20: Check for tables starting with 'Z' in the database:\\n\"
      
ztables=\$(sqlplus -S \$ATADBACONNECT <<SQL
SET PAGESIZE 0
SET FEEDBACK OFF
SET LINESIZE 32000
SET TAB OFF
SET TIMING OFF
SELECT table_name FROM all_tables WHERE table_name LIKE 'Z%';
SQL
)

ztables2=\$(echo "\$ztables")
if [ \"\$ztables2\" = 'no rows selected' ]; then
			echo "20- [COMMENT]  No tables starting with 'Z' found: \$ztables2"
		else
		echo "20- [ALERT]  Tables starting with 'Z' found:"
        echo "\$ztables2"
 		fi
                
        echo -e \"-----\\nSECTION 21: SVSC process SV$((i+1)): ${instances_array[$i]} \\n\"
        output=\$( ataprocs | grep svsc | wc -l)
        if [ \${output} -ge 1 ]; then
        	echo "21- [COMMENT] SVSC process is running "
          	echo -e \"\\n\"
		else
        	echo "21- [WARNING] SVSC process is not running, Please Check SECTION 9 if it needs to be running in this SV Instance."
         	echo -e \"\\n\"
        fi 
        echo -e "SV VERSION SV$((i+1))"
        svversion 2>&1
        echo -e "................................................................."
        echo -e "................................................................."
" >> $NODE_NAME.txt                     
done

echo -e "Hi,\nPost release installation log has been attached " | mail -a $ATA_HOME/work/jenkins/workspace/SPR_CheckList/${NODE_NAME}.txt -s "Post release installation log - $NODE_NAME"  List-GLB-Client1-SV-ES@company.com

# Disable debug mode
set +x

echo -e "*******************************************\nProcess ended: $(date) $(TZ) \n*******************************************\n" >>  $NODE_NAME.txt


  