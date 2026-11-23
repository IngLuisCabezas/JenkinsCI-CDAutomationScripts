#!/bin/ksh

# Environment variables
export TZ="UTC"
time_max=30

# Define array 
set -A hosts \
  "c1sbx1b@host02" \
  "c1socs1b@host03"

# Starting Script
echo -e "\n*********************************************\nProcess started: $(date)\n*********************************************\n"

# Remote command
remote_command='
  . ~/.profile > /dev/null
  jpup=$(ps -fu ${ENVIRONMENT_NAME} | grep jenkins | wc -l)
  if [[ $jpup -gt 2 ]]; then
    echo -e "$jpup Node ${ENVIRONMENT_NAME} is already ONLINE."
  else
  	/c1/${ENVIRONMENT_NAME}/work/jenkins/bin/jenkins_slave_start.ksh
    echo -e "$jpup Node ${ENVIRONMENT_NAME} is STARTED."
  fi
'

# Loop over hosts
for host in "${hosts[@]}"; do
  timeout "$time_max" ssh -q -T "$host" "$remote_command"  || echo -e "There is not connectivity -> ssh $host"
done

# Ending Script
echo -e "\n*******************************************\nProcess ended: $(date)\n*******************************************\n"

#v1.0 22-may-2025 MW Dev CORP Env.