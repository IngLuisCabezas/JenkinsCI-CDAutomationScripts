#!/bin/bash

#Enable debug mode
set -x

#Environment variables
export TZ="UTC"  
date=`date "+%Y%m%d%H%M%S"`
sv_user=$(whoami)

#Starting Scrtip
echo -e "--------------------------------------------------\n Starting at $(date) $(TZ) \n--------------------------------------------------\n" >  $NODE_NAME.txt
echo "SINGLEVIEW ENV BACKUP: $NODE_NAME  $sv_user" >>  $NODE_NAME.txt
echo -e "\n" >>  $NODE_NAME.txt

instances_array=($(da_dump InstanceStatus | sed -n 1!p | awk -F '"*,"*' '{print $24}'))

# Check the value of the boolean variable
if [ "$FILE_SYSTEMS" = true ]; then
   echo "SINGLEVIEW FILE SYSTEMS BACKUP: $NODE_NAME \n" >>  ${NODE_NAME}_FS_BK_LOG.txt
   echo "SINGLEVIEW FILE SYSTEMS BACKUP: $NODE_NAME \n" >>  $NODE_NAME.txt
   
   for ((i=0; i<${#instances_array[@]}; i++)); do
        ssh -q "$sv_user@${instances_array[$i]}" <<EOF 
                        set -x
                        if [ $i -eq 0 ]; then
                            #sv_stop -cluster 2>&1
                        	#billing_clean `whoami` -r -F  
							#ipcrm -a                  
                        	#ipcs -a
                       		cd $ATA_HOME;
                           	pwd;
                            #tar -cvzf ${ORACLE_SID}_SV$((i+1))_$date.tar.gz imp admin rel sv cmuplift CVS diameter http2 kafka px pxenv perx-cb-11.00.03 .perlenv .gsenv .orapathenv diameterenv http2env kafkaenv --exclude=data/server/log.old --exclude=data/server/log data                            
                            tar -cvzf ${ORACLE_SID}_SV$((i+1))_$date.tar.gz imp rel sv cmuplift CVS diameter http2 kafka px pxenv perx-cb-11.00.03 .perlenv .gsenv .orapathenv diameterenv http2env kafkaenv --exclude=admin/releases/*.tar.gz admin --exclude=data/server/log.old --exclude=data/server/log data 
                            mkdir BACKUPS
                            mv ${ORACLE_SID}_SV$((i+1))_$date.tar.gz ./BACKUPS
                            ls -lart BACKUPS
                       else  
                        	#billing_clean `whoami` -r -F  
							#ipcrm -a                  
                        	#ipcs -a                       
                        	cd $ATA_HOME;
                        	pwd;   
                            #tar -cvzf ${ORACLE_SID}_SV$((i+1))_$date.tar.gz imp admin rel sv cmuplift CVS diameter http2 kafka px pxenv perx-cb-11.00.03 .perlenv .gsenv .orapathenv diameterenv http2env kafkaenv --exclude=data/server/log.old --exclude=data/server/log data
                            tar -cvzf ${ORACLE_SID}_SV$((i+1))_$date.tar.gz imp rel sv cmuplift CVS diameter http2 kafka px pxenv perx-cb-11.00.03 .perlenv .gsenv .orapathenv diameterenv http2env kafkaenv --exclude=admin/releases/*.tar.gz admin --exclude=data/server/log.old --exclude=data/server/log data 
                            mkdir BACKUPS
                            mv ${ORACLE_SID}_SV$((i+1))_$date.tar.gz ./BACKUPS
                            ls -lart BACKUPS
                        fi
                        set +x
EOF
	done
    for ((i=0; i<${#instances_array[@]}; i++)); do
	ssh -q "$sv_user@${instances_array[$i]}" <<EOF >>  ${NODE_NAME}_FS_BK_LOG.txt
                        	echo -e "\nSV$((i+1))"
                       		cd $ATA_HOME;
							pwd;
                            echo -e "\n Backup Directory: $ATA_HOME/BACKUPS"
                        	ls -lh BACKUPS | grep ${ORACLE_SID}_SV$((i+1))_$date.tar.gz
                            echo -e "\n \n"               
EOF

	done
else
	echo -e "NOT FILE SYSTEMS BACKUP NEEDED\n" >> $NODE_NAME.txt
    if [ "$DB_BACKUP_OPTIONS" == "NO_DB_BACKUP" ]; then
    	echo -e "NOT DB BACKUP NEEDED \n" >> "$NODE_NAME.txt"
    	echo -e "SELECT AN OPTION \n" >> "$NODE_NAME.txt"
        exit 1
	fi
fi

if [ "$DB_BACKUP_OPTIONS" == "EXPORT_DB" ]; then

    echo -e "EXPORT_DB BACKUP SELECTED \n" >>  ${NODE_NAME}_EXPORT_DB_LOG.txt
    echo -e "EXPORT_DB BACKUP SELECTED \n" >>  $NODE_NAME.txt
    
    ssh -q "$sv_user@${instances_array[0]}" <<EOF >>  ${NODE_NAME}_EXPORT_DB_LOG.txt 
        cd $ATA_HOME;
        echo -e "\n \n"
        export_db -d DATA_PUMP_DIR -n 8 -f ${ORACLE_SID}_DB_%U_$date.dmp
	    echo -e "\n Default PUMP Directory Path on DB: /u01/c1_app/oracle/admin/${ORACLE_SID}/dpdump"
EOF

fi

if [ "$DB_BACKUP_OPTIONS" == "FLASHBACK" ]; then

    echo -e "FLASHBACK BACKUP SELECTED \n" >>  ${NODE_NAME}_FLASHBACK_DB_LOG.txt
    echo -e "FLASHBACK BACKUP SELECTED \n" >>  $NODE_NAME.txt
    
    ssh $sv_user@${instances_array[0]} "
            source ~/.profile > /dev/null
	        database='v\$database';
            restore_point='v\$restore_point';
            rp_name="${NODE_NAME}_${date}";
            echo -e \"\\n\"
            echo -e \"Restore point that will be created: \$rp_name\"
            echo -e \"\\n\"
			sqlplus -S sys/manager as sysdba <<SQL
            set markup csv on; 
            select log_mode from \$database;         
            create restore point \$rp_name guarantee flashback database;
            select TIME,RESTORE_POINT_TIME,PRESERVED,NAME from \$restore_point ORDER BY TIME DESC;
            set markup csv off;
SQL
" >>  ${NODE_NAME}_FLASHBACK_DB_LOG.txt

fi

#Ending Scrtip
echo -e "--------------------------------------------------\n Ending at $(date) $(TZ) \n--------------------------------------------------\n" >>  $NODE_NAME.txt

# Disable debug mode
set +x