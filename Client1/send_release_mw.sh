#!/bin/ksh

# Define a log file
# LOGFILE="$BUILD_ID.log"
# Redirect all output (stdout and stderr) to the log file
# exec > "$LOGFILE" 2>&1
 
# Environment variables
export TZ="UTC"
export JENKINS_JOBS="/c1/c1_app/jenkins/jobs"
export time_max=40

# Generate timestamp in milliseconds
TIMESTAMP=$(($(date +%s)*1000))

# Starting Script
echo -e "\n*********************************************\nProcess started: $(date)\n*********************************************\n"

# Enable debug mode
# set -x
if [ -d "$JENKINS_JOBS/$STORAGE/builds/$RELEASE_JOB_NUM/archive" ]; then 
    # Local directory exists. Creating remote directory...
    # Create remote directory
    timeout "$time_max" ssh -q -p 47001 c1_app@xx.47.113.xx \
    "mkdir -p $JENKINS_JOBS/C1DEV1B/builds/$RELEASE_JOB_NUM/archive && echo '[COMMENT]: Remote directory created successfully.'"
    # Copy artifact archive
    timeout "$time_max" scp -P 47001 -r $JENKINS_JOBS/$STORAGE/builds/$RELEASE_JOB_NUM/archive  c1_app@xx.47.113.xx:$JENKINS_JOBS/C1DEV1B/builds/$RELEASE_JOB_NUM > /dev/null 2>&1 \
    && echo "[COMMENT]: Release Job Build $RELEASE_JOB_NUM in $STORAGE has been sent correctly to MW Env"    
    # Create remote build.xml
    timeout "$time_max" ssh -q -p 47001 -T c1_app@xx.47.113.xx 'bash -s' <<EOF
    export TERM=dumb
cat <<XML > $JENKINS_JOBS/C1DEV1B/builds/$RELEASE_JOB_NUM/build.xml
<build>
  <number>$RELEASE_JOB_NUM</number>
  <result>SUCCESS</result>
  <timestamp>$TIMESTAMP</timestamp>
  <duration>1000</duration>
</build>
XML
EOF
# Check exit status of SSH command
	if [ $? -ne 0 ]; then
 	 	echo "[ALERT]: SSH command failed - build has not been created for Job Build $RELEASE_JOB_NUM in MW Env."
        echo -e "*******************************************\nProcess ended: $(date)\n*******************************************\n"
  		exit 1
	else
  		echo -e "[COMMENT]: Job Build $RELEASE_JOB_NUM created successfully in MW Env.\n"
	fi
    
else
    echo -e "Release Job Build $RELEASE_JOB_NUM in $STORAGE does not exist.\n"
    echo -e "*******************************************\nProcess ended: $(date)\n*******************************************\n"
    exit 1
fi

# Disable debug mode
# set +x

# Ending Script
echo -e "*******************************************\nProcess ended: $(date)\n*******************************************\n"

#v1.1 23-may-2025