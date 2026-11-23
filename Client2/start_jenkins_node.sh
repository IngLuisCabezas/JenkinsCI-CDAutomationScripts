#!/bin/ksh

# Environment variables
export TZ="UTC"
time_max=30
# Define array 
. ${JENKINS_HOME}/workspace/src/environments
# Convert multiline variable into array in ksh
set -A hosts $(echo "$sv_envs")

# Artifact -> Same Console
exec 2>/dev/null

# Starting Script
echo -e "\n*********************************************\nProcess started: $(date)\n*********************************************\n"

# Remote command
remote_command='
  . ~/.profile > /dev/null
  jpup=$(ps -fu ${ENVIRONMENT_NAME} | grep jenkins | wc -l)
  if [[ $jpup -gt 2 ]]; then
    echo -e "$jpup Node ${ENVIRONMENT_NAME} is already ONLINE."
  else
  	$ATA_HOME/work/jenkins/bin/jenkins_slave_start.ksh
    echo -e "$jpup Node ${ENVIRONMENT_NAME} is STARTED."
  fi
'
# Loop over hosts
for host in "${hosts[@]}"; do
  timeout "$time_max" ssh -q -T "$host" "$remote_command" || echo -e "[ALERT]: Please, validate timed out -> ssh $host" 
done

# Ending Script
echo -e "\n*******************************************\nProcess ended: $(date)\n*******************************************\n"


#app.app.host16> (/sv/sv_app/jenkins/workspace/src)
#$ cat environments
## POSIX-compatible array emulation
#SV_ENVS="
#svppd1b@host13
#svuat1b@host15
#svsit1b@host09
#svpoc1b@host10
#svtrn1b@host14
#svdev1b@host12
#"
