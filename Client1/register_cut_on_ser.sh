#!/bin/bash

#Enable debug mode
set -x

#Environment variables
export TZ="UTC"

#Starting Scrtip
echo -e "--------------------------------------------------\n Starting at $(date) $(TZ) \n--------------------------------------------------\n" >  $WORKSPACE/artifact.txt

file=$(find /c1/c1_app/jenkins/jobs/$TRIGGERED_PROJECT/builds/$TRIGGERED_BUILD_NUMBER/archive/ -type f -name "C1_*.xml") 
echo "SER Client1 Release $TRIGGERED_PROJECT $TRIGGERED_BUILD_NUMBER" | mail -a ${file} -s "Register Client1 Release $TRIGGERED_PROJECT $TRIGGERED_BUILD_NUMBER" sv-env-register@company.com user01@company.com
echo "Upstream Project: $TRIGGERED_PROJECT"  >> $WORKSPACE/artifact.txt
echo "Upstream Build #: $TRIGGERED_BUILD_NUMBER" >> $WORKSPACE/artifact.txt
echo "File: $file" >> $WORKSPACE/artifact.txt

#Ending Scrtip
echo -e "--------------------------------------------------\n Ending at $(date) $(TZ) \n--------------------------------------------------\n" >>  $WORKSPACE/artifact.txt

# Disable debug mode
set +x
