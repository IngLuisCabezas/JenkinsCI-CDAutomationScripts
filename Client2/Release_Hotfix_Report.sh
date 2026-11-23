#!/bin/bash

report_name="Client2 Release and Hotfix Information Report"
output_file="Client2_CORP_Hosted_SV_Report.html"
report_path="/c2/c2_app/jenkins/workspace/env_release_report"

#email_list="user01@company.com"

email_list="List-Glob-Client2-Release-Management-Team@company.com \
List-Client2PlatformEngineering@company.com"

time_max=2

IFS=',' read -ra sv_envs <<< "c2bld1b@host04,\
c2sbx1b@host04,\
c2har1b@host05,\
c2ust1b@host06,\
c2ust2b@host07,\
c2tfd1b@host08,\
c2ppd1b@xx.13.50.xx,\
c2bld3b@host11,\
m11dev5b@host01"

#IFS=',' read -ra sv_envs <<< "c2sbx1b@host04"

cat <<EOF > "$output_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$report_name</title> 
</head>
<body>
    <h1 style="text-align:center; margin-top:40px;">
        <br><br><font color='green'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $report_name</font> &nbsp;&nbsp;
    </h1>

    <p style="text-align:center; font-size:16px; margin-top:20px;">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; List of the latest Minor, Major, Rollup, or Patch release deployed, 
        along with all patches and hotfixes applied to each environment since the release installation.
    </p>
</body>
EOF
    
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
            echo -e  \"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><font color='red'>[ALERT]: Env \$ORACLE_SID - Database connection could not be established, please check it.</font></b><br><br> \"
        exit 
        fi
        
        version=\$(sqlplus \$ATADBACONNECT <<'EOF'|grep Version |tail -1
        EXIT;
EOF
)
        echo -e \"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \$ORACLE_SID = \$version <br> \"
        
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
    ri.INSTALL_DATE >= (
        SELECT MAX(INSTALL_DATE)
        FROM release_info
        WHERE INSTALL_TYPE IN ('Minor', 'Patch', 'Rollup', 'Major')
    )
ORDER BY
    ri.INSTALL_DATE DESC;

set markup html off;
 
SQL

" >> $output_file

    # Check if timeout occurred
    exit_code=$?
    if [[ $exit_code -eq 124 ]]; then
        echo -e "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><font color='red'>[ALERT]: Ssh ${svconnect} - Timed out, please check it.</font></b><br><br>" >> "$output_file"
    fi

done
echo -e " </html> "  >> $output_file
   
# Enable debug mode
set -x

for attempt in {1..1}; do
mail -a "$report_path/$output_file" \
     -s "$report_name" \
     -r "Client2 CORP Jenkins <jenkins@host06>" \
     $email_list <<EOF

Hi Client2 Release Management Team,

CORP Dev Hosted SingleView Client2 envs report has been attached.

This is an automated message. If you have any questions or need assistance, please contact the PE team at:
List-Client2PlatformEngineering@company.com
EOF
sleep 1

echo -e "\n[INFO]: Email has been Sent \n"
done
# Disable debug mode
set +x