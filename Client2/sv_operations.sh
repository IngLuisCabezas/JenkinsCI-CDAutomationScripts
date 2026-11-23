#!/bin/bash

# Environment variables
# Host variables
export TZ="UTC"
sv_user=$(whoami)
# Jenkins variables
# SV_OPERATION -> Pass it explicitly to SSH
output_file=$NODE_NAME.log
# SSH Variables
#host="${instances_array[$i]}"
#sv_type=1 Single-Inst SV1
#sv_type=2 Multi-Inst: Just SV1
#sv_type=3 Multi-Inst: SVx 

# Redirect output (stdout) and errors (stderr)
exec > >(tee -a "$output_file") 2>/dev/null

# Functions
finished_script() {
echo -e "\n-------------------------------------------\nProcess ended: $(date)\n-------------------------------------------\n"
}

# Starting Script
echo -e "\n\n---------------------------------------------\nProcess started: $(date)\n---------------------------------------------\n"
echo -e "Singleview Operations\n\nEnvironment: ${NODE_NAME^^}\n"
echo -e  "\n|==> SV_OPERATION selected: ${SV_OPERATION}\n"
# Go through every single instance
instances_array=($(da_dump InstanceStatus | sed -n 1!p | awk -F '"*,"*' '{print $24}'))

for ((i=0; i<${#instances_array[@]}; i++)); do
    host="${instances_array[$i]}"
    
    HA=$(env | grep 'HA_ACTIVE=1' | wc -l)
    if [ "$HA" -eq "1" ]; then
        echo  "|==> [Fail] HA is active on this environment: ${NODE_NAME^^}. Operation is not allowed."
        finished_script
        exit 1
    fi
    
# SV Instance Type
	if [ "${#instances_array[@]}" -eq 1 ]; then
    	sv_type=1      
	else
    	if [ "$i" -eq 0 ]; then
        	sv_type=2
   		else
       		sv_type=3   
    	fi
	fi
   
# Pass SV_OPERATION and sv_type variable, execute ksh.
    ssh "$sv_user@$host" 'ksh -s' -- "$SV_OPERATION" "$sv_type" "$i" "$host" <<'REMOTE_KSH'
# Remote side (ksh)
# set -eu
set -u

# Receive arguments
SV_OPERATION="$1"
sv_type="$2"
i="$3"
instance="$4"

# load remote env variables.
[ -f "$HOME/.profile" ] && . "$HOME/.profile" >/dev/null 2>&1 || true

# Function

run_sv_status () {
typeset svi="$1"
print "|==> [sv_status] $(whoami):SV$((svi+1)):${sv_host}"
print ""
sv_status 2>&1
print ""
print "|==> [svstatus] $(whoami):SV$((svi+1)):${sv_host}"
print ""
svstatus 2>&1
}

run_pu() {
typeset svi="$1"
print "" 
print "|==> [pu] $(whoami):SV$((svi+1)):${sv_host}"
print "" 
ps -fu "$USER" 2>&1
print "" 
}

run_sv_operations() {
    typeset sv_option="$1"
    typeset sv_type="$2"
    typeset svi="$3"
    typeset sv_host="$4"
    typeset key="${sv_option}_${sv_type}"
    print ""
    case "$key" in
        SV_STATUS_1)
            #sv_type=1 Single-Inst SV1
            run_sv_status "$svi"
            ;;
        SV_STATUS_2)
            #sv_type=2 Multi-Inst: Just SV1
            print "|==> [sv_status -cluster] $(whoami):SV$((svi+1)):${sv_host}"
            print "" 
            sv_status -cluster 2>&1
            run_sv_status "$svi"
            ;;
        SV_STATUS_3)
            #sv_type=3 Multi-Inst: SVx 
            run_sv_status "$svi"
            ;;
        SV_START_1)
            #sv_type=1 Single-Inst SV1
            print "|==> [sv_start] $(whoami):SV$((svi+1)):${sv_host}"
            print "" 
            sv_start 2>&1
            run_sv_status "$svi"
            ;;
        SV_START_2)
            #sv_type=2 Multi-Inst: Just SV1
            print "|==> [sv_start -cluster] $(whoami):SV$((svi+1)):${sv_host}"
            print "" 
            sv_start -cluster 2>&1
            run_sv_status "$svi"
            ;;
        SV_START_3)
            #sv_type=3 Multi-Inst: SVx 
            run_sv_status "$svi"
            ;;
        SV_STOP_1)
            #sv_type=1 Single-Inst SV1
            print "|==> [sv_stop] $(whoami):SV$((svi+1)):${sv_host}"
            print "" 
            sv_stop || sv_stop -kill || sv_stop -kill -kill; ipcrm -a 2>&1
            run_pu "$svi"
            run_sv_status "$svi"
            ;;
        SV_STOP_2)
            #sv_type=2 Multi-Inst: Just SV1
            print "|==> [sv_stop -cluster] $(whoami):SV$((svi+1)):${sv_host}"
            print "" 
            sv_stop -cluster  || sv_stop -cluster -kill || sv_stop -cluster -kill -kill; ipcrm -a 2>&1
            run_pu "$svi"
            run_sv_status "$svi"
            ;;
        SV_STOP_3)
            #sv_type=3 Multi-Inst: SVx 
            ipcrm -a 2>&1
            run_pu "$svi"
            run_sv_status "$svi"
            ;;      
    esac
}

run_sv_operations "$SV_OPERATION" "$sv_type" "$i" "$instance"

REMOTE_KSH

done

finished_script
