#!/bin/bash

IFS=',' read -ra sv_envs <<< "c1dev1b@xx.19.52.xx,c1dev1b@xx.19.109.xx,c1devm1b@xx.19.52.xx,c1devmocs1b@xx.19.109.xx,c1bld1b@xx.19.52.xx,c1bld2b@xx.19.52.xx,c1tm1b@xx.19.52.xx,c1tmocs1b@xx.19.109.xx,c1tst1b@xx.19.52.xx,c1tstocs1b@xx.19.109.xx,c1tst2b@xx.19.52.xx,c1tstocs2b@xx.19.109.xx,c1tst3b@xx.19.52.xx,c1tstocs3b@xx.19.109.xx,c1har1b@xx.19.52.xx,c1harocs1b@xx.19.109.xx,c1kyhrocs1b@xx.19.111.xx,c1bbhocs1b@xx.19.112.xx,c1auhocs1b@xx.19.114.xx,c1har2b@xx.19.52.xx,c1kyhocs2b@xx.19.111.xx,c1bbhocs2b@xx.19.112.xx,c1auhocs2b@xx.19.114.xx,c1ref1b@xx.19.52.xx,c1ref2b@xx.19.52.xx,c1refp1b@xx.19.53.xx,c1mnt1b@xx.19.52.xx,c1kymocs1b@xx.19.111.xx,c1bbmocs1b@xx.19.112.xx,c1aumocs1b@xx.19.4.xx,c1trncc1b@xx.19.52.xx,c1trnce1b@xx.19.52.xx,c1sit1b@xx.19.52.xx,c1kysocs1b@xx.18.141.xx,c1bbsocs1b@xx.18.38.xx,c1ausocs1b@xx.21.158.xx,c1uatu1b@xx.19.52.xx,c1kyuocs1b@xx.18.141.xx,c1bbuocs1b@xx.18.38.xx,c1auuocs1b@xx.21.158.xx,c1prf1b@xx.19.52.xx,c1prfocs1b@xx.19.109.xx,c1pre1b@xx.19.52.xx,c1kyppocs1b@xx.19.115.xx,c1bbppocs1b@xx.19.124.xx,c1auppocs1b@xx.19.4.xx,c1prd1b@xx.19.53.xx,c1cypocs1b@xx.19.115.xx,c1bbpocs1b@xx.19.124.xx,c1aupocs1b@xx.19.4.xx,c1ref3b@xx.19.47.xx,c1refocs3b@xx.19.47.xx"
#IFS=',' read -ra sv_envs <<< "c1dev1b@xx.19.52.xx,c1dev1b@xx.19.109.xx,c1devm1b@xx.19.52.xx"
echo -e " <!DOCTYPE html> "  >> Client1SVrelInf.html
echo -e " <html lang="en"> "  >> Client1SVrelInf.html
echo -e " <head> "  >> Client1SVrelInf.html
echo -e "     <meta charset="UTF-8"> "  >> Client1SVrelInf.html
echo -e "     <meta name="viewport" content="width=device-width, initial-scale=1.0"> "  >> Client1SVrelInf.html
echo -e "     <title>SingleView Release Report</title> "  >> Client1SVrelInf.html
echo -e " </head> "  >> Client1SVrelInf.html
echo -e " <body> "  >> Client1SVrelInf.html
echo -e "    <h1><br> <br> &nbsp;  &nbsp;  &nbsp;  &nbsp; &nbsp;  &nbsp;  &nbsp;  &nbsp;  Client1 SingleView Environment Release Information Report &nbsp; &nbsp;   </h1> " >> Client1SVrelInf.html
echo -e " </body> "  >> Client1SVrelInf.html

time_max=30
    
for i in "${!sv_envs[@]}"; do
	svconnect="${sv_envs[$i]}"
            
timeout ${time_max}	ssh ${svconnect} "
    
		source ~/.profile > /dev/null
		instance='v\$instance'

        # Test SQL*Plus connection
        sqlplus_output=\$(sqlplus \$ATADBACONNECT <<EOF
        EXIT;
EOF
)
        # Check if connection was successful
        if [[ \"\$sqlplus_output\" == *\"Connected to:\"* ]]; then
            echo -e \"Env <b>\$ORACLE_SID</b><br> \" > /dev/null
        else
            echo -e \"<b>[ALERT]: Env \$ORACLE_SID</b> - Unable to connect to database. <br>  <br> \"
            exit 
        fi
        
        version=\$(sqlplus \$ATADBACONNECT <<'EOF'|grep Version |tail -1
        EXIT;
EOF
)
        echo -e \"Oracle Version \$ORACLE_SID = \$version <br> \"
        
sqlplus -S \$ATADBACONNECT <<SQL

    set feedback off
    set verify off
    set sqlblanklines off
    set timing off
    set pagesize 50000
    set linesize 1500
    
    SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP OFF -
   
	SELECT
	(SELECT instance_name FROM \$instance) AS ENVIRONMENT,
    ri.RELEASE_ID,
    ri.DESCRIPTION,
    ri.INSTALL_TYPE,
    ri.INSTALL_DATE
	FROM
   		release_info ri
	WHERE
    	ri.INSTALL_DATE >= (SELECT MAX(INSTALL_DATE) FROM release_info WHERE RELEASE_ID LIKE 'C1%')
	ORDER BY
    	ri.INSTALL_DATE DESC;

set markup html off;
 
SQL

" >> Client1SVrelInf.html

done
echo -e " </html> "  >> Client1SVrelInf.html

# Enable debug mode
#set -x

for attempt in {1..5}; do
mail -a "/c1/c1_app/jenkins/workspace/SV_Env_Release_Info/Client1SVrelInf.html" \
     -s "Client1 SingleView Envs Release Information" \
     List-GLB-Client1-SV-ES@company.com \
     ListClient1RelMgmtGlobal@company.com \
     user08@company.com \
     user02@company.com \
     user06@company.com \
     user07@company.com \
     user03@company.com <<EOF
Hi Elizabeth,

Completed Client1 SingleView Environment Release Information Report has been attached.

This is an automated message. If you have any questions or need assistance, please contact the PE team at:
List-GLB-Client1-SV-ES@company.com
EOF
sleep 40    
echo -e "\n[INFO]: Email has been Sent \n"
done
# Disable debug mode
#set +x