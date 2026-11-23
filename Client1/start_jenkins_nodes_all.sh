#!/bin/ksh

# Environment variables
export TZ="UTC"
time_max=30

# Define array 
set -A hosts \
    "c1dev1b@xx.19.52.xx" "c1dev1b@xx.19.109.xx" \
    "c1devm1b@xx.19.52.xx" "c1devmocs1b@xx.19.109.xx" \
    "c1bld1b@xx.19.52.xx" \
    "c1bld2b@xx.19.52.xx" \
    "c1tst1b@xx.19.52.xx" "c1tstocs1b@xx.19.109.xx" \
    "c1tst2b@xx.19.52.xx" "c1tstocs2b@xx.19.109.xx" \
    "c1tst3b@xx.19.52.xx" "c1tstocs3b@xx.19.109.xx" \
    "c1tst4b@xx.19.52.xx" "c1tstocs4b@xx.19.109.xx" \
    "c1tm1b@xx.19.52.xx" "c1tmocs1b@xx.19.109.xx" \
    "c1trncc1b@xx.19.52.xx" "c1trnce1b@xx.19.52.xx"\
    "c1ref1b@xx.19.52.xx" \
    "c1ref2b@xx.19.52.xx" "c1refp1b@xx.19.53.xx"  \
    "c1ref3b@xx.19.47.xx" "c1refocs3b@xx.19.47.xx" \
    "c1har1b@xx.19.52.xx" "c1harocs1b@xx.19.109.xx" "c1kyhrocs1b@xx.19.111.xx" "c1bbhocs1b@xx.19.112.xx" "c1auhocs1b@xx.19.114.xx" \
    "c1har2b@xx.19.52.xx" "c1kyhocs2b@xx.19.111.xx" "c1bbhocs2b@xx.19.112.xx" "c1auhocs2b@xx.19.114.xx" \
    "c1mnt1b@xx.19.52.xx" "c1kymocs1b@xx.19.111.xx" "c1bbmocs1b@xx.19.112.xx" "c1aumocs1b@xx.19.4.xx" \
    "c1uatu1b@xx.19.52.xx" "c1auuocs1b@xx.21.158.xx" "c1kyuocs1b@xx.18.141.xx" "c1bbuocs1b@xx.18.38.xx" \
    "c1sit1b@xx.19.52.xx" "c1kysocs1b@xx.18.141.xx" "c1bbsocs1b@xx.18.38.xx" "c1ausocs1b@xx.21.158.xx" \
    "c1prf1b@xx.19.52.xx" "c1prfocs1b@xx.19.109.xx" \
    "c1mig1b@xx.19.52.xx" "c1mco1b@xx.19.52.xx" "c1mbo1b@xx.19.52.xx" "c1mao1b@xx.19.52.xx" \
    "c1mig3b@xx.19.52.xx" "c1migocs3b@xx.19.52.xx" "c1migocs3c@xx.19.52.xx" "c1migocs3d@xx.19.52.xx" \
    "c1mig4b@xx.19.52.xx" "c1mbo4b@xx.19.52.xx" "c1mco4b@xx.19.52.xx" "c1mao4b@xx.19.52.xx" \
    "c1pre1b@xx.19.52.xx" "c1kyppocs1b@xx.19.115.xx" "c1bbppocs1b@xx.19.124.xx" "c1auppocs1b@xx.19.4.xx" \
    "c1prd1b@xx.19.53.xx" "c1cypocs1b@xx.19.115.xx" "c1bbpocs1b@xx.19.124.xx" "c1aupocs1b@xx.19.4.xx"   

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
  timeout "$time_max" ssh -q -T "$host" "$remote_command"  || echo -e "[ALERT]: Please, validate that there is not connectivity -> ssh $host"
done

# Ending Script
echo -e "\n*******************************************\nProcess ended: $(date)\n*******************************************\n"

#v1.0 22-may-2025 C1 Envs