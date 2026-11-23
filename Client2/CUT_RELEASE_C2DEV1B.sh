#!/bin/bash
######################################### PRE-CHEKC ###############################################
REQUIRED_GB=10               # minimum free space required
DIR=$WORKSPACE               # directory to validate
# Get available space in GB (integer)
AVAILABLE_GB=$(df -BG "$DIR" | awk 'NR==2 {gsub("G","",$4); print $4}')
if (( AVAILABLE_GB < REQUIRED_GB )); then
    echo -e  "\n---------------------------------------------------------------------------------------------------------------------------"
    echo -e "[ALERT] ERROR: Not enough free space in ${WORKSPACE} to CUT RELEASE. Required: ${REQUIRED_GB}GB, Available: ${AVAILABLE_GB}GB"
    echo -e  "----------------------------------------------------------------------------------------------------------------------------\n"
    exit 1
else
    echo -e  "\n---------------------------------------------------------------------------------------------------------------------------"
    echo "Free space in $DIR: ${AVAILABLE_GB}GB, Enough free space to CUT RELEASE. Continuing..."
    echo -e  "---------------------------------------------------------------------------------------------------------------------------\n"
fi

######################################### RELEASE CUT #################################################
cd $ATA_HOME/work/jenkins/bin
./cut_release -r $RELEASE_CODE -t $RELEASE_TYPE -m $RELEASE_MODE -p $PROJECT_CODE

######################################### NOTIFICATIONS ###############################################
mail \
    -a "$WORKSPACE/${PROJECT_CODE}_${RELEASE_CODE}_${RELEASE_TYPE}_${RELEASE_MODE}_errors_report.html" \
    -a "$WORKSPACE/${PROJECT_CODE}_${RELEASE_CODE}_ticket_report.html" \
    -a "$WORKSPACE/${PROJECT_CODE}_${RELEASE_CODE}_ise_report.html" \
    -a "$WORKSPACE/${PROJECT_CODE}_${RELEASE_CODE}_bom_report.html" \
    -s "${NODE_NAME} Release Cut: ${PROJECT_CODE}_${RELEASE_CODE}_${RELEASE_TYPE}_${RELEASE_MODE} Jenkins Job#:${BUILD_NUMBER}" \
    -r "Client2 CORP Jenkins <jenkins@host06>" \
    user01@company.com <<EOF
Hi Client2 Release Management Team,

The Cut has been successfully completed. 
ENVIRONMENT: ${NODE_NAME}
ID Jenkins Job:${BUILD_NUMBER}

The most important reports have been attached:
Dev Cut Release Errors Report: ${PROJECT_CODE}_${RELEASE_CODE}_${RELEASE_TYPE}_${RELEASE_MODE}_errors_report.html
Tickets Release Report: ${PROJECT_CODE}_${RELEASE_CODE}_ticket_report.html
Release Installation Script Extension Report: ${PROJECT_CODE}_${RELEASE_CODE}_ise_report.html
Release Bill of Materials Report: ${PROJECT_CODE}_${RELEASE_CODE}_bom_report.html

This is an automated message. If you have any questions or need assistance, please contact the PE team at:  
List-Client2PlatformEngineering@company.com
EOF
