#!/bin/bash

######################################### PRE-CHECk ###############################################
REQUIRED_GB=10              # minimum free space required
DIR=$WORKSPACE               # directory to validate
# Get available space in GB (integer)
AVAILABLE_GB=$(df -BG "$DIR" | awk 'NR==2 {gsub("G","",$4); print $4}')
if (( AVAILABLE_GB < REQUIRED_GB )); then
    echo -e "\n---------------------------------------------------------------------------------------------------------------------------------------------------------"
    echo -e "[ALERT] ERROR: Not enough free space in ${WORKSPACE} to INSTALL RELEASE. Required: ${REQUIRED_GB}GB, Available: ${AVAILABLE_GB}GB"
    echo -e  "---------------------------------------------------------------------------------------------------------------------------------------------------------\n"
    exit 1
else
    echo -e  "\n---------------------------------------------------------------------------------------------------------------------------------"
    echo "Free space in $DIR: ${AVAILABLE_GB}GB, Enough free space to INSTALL RELEASE. Continuing..."
    echo -e  "---------------------------------------------------------------------------------------------------------------------------------\n"
fi

############################# CHECK 6 DIGITS AFTER (.) #############################
    echo -e  "-------------------------------------------------------"
    echo "STEP NUMBER TO START RELEASE INSTALLATION: ${STEP_NUM}"
    echo -e  "-------------------------------------------------------\n"   
if [[ ${STEP_NUM} == *"."* ]]; then
    STEP_NUM_C=${STEP_NUM#*.}
    CHARNUM=($(echo -n $STEP_NUM_C | wc -c))    
    if [[ $CHARNUM != 6 ]]; then
        echo -e  "----------------------------------------------------------------------------------------------------------------"    
        echo "[ALERT] ERROR: STEP_NUMBER variable after (.) must have 6 digits ( Example: xx.xxxxxx). Found $CHARNUM, STEP_NUM=${STEP_NUM}";
        echo -e  "----------------------------------------------------------------------------------------------------------------"   	          
        exit 1
	fi
fi

############################# FIND MAKE CUT ERRROS #############################
REL_LOG="${PROJECT_CODE}_${RELEASE_CODE}_${RELEASE_TYPE}_${RELEASE_MODE}.log"
if [ "$OVERRIDE_PRECHECK_MAKEFILE_CUT_ERRORS_FOUND" = true ]; then  
   if [ ! -f "$REL_LOG" ]; then  
       echo -e "\n--------------------------------------------------------------------------------------------"
       echo -e "[ALERT]: MAKEFILE CUT ERRORS NOT FOUND. File does NOT exist: $REL_LOG"
       echo -e "--------------------------------------------------------------------------------------------\n"    
       exit 1
   fi 
   output=$(cat $REL_LOG | grep E03003 | wc -l)
   if [ ${output} -ge 1 ]; then
    	echo -e "\n-----------------------------------------------------------------------------------------------------------------"
   		echo -e "[ALERT]: Makefile cut errors found for this Bundle, check ${PROJECT_CODE}_${RELEASE_CODE}_${RELEASE_TYPE}_${RELEASE_MODE}.make_cut.log "
    	echo -e  "-----------------------------------------------------------------------------------------------------------------\n" 
        cat $REL_LOG | grep E03003 > ${PROJECT_CODE}_${RELEASE_CODE}_${RELEASE_TYPE}_${RELEASE_MODE}.make_cut.log
        echo -e "\n------------------------------------------------------------"
        echo -e "[ALERT]: Aborted install release"
        echo -e "--------------------------------------------------------------\n"
	    exit 1	
    else
        echo -e "\n------------------------------------------------------------"
        echo -e "[INFO]: No makefile cut errors found. Everything is fine."
        echo -e "--------------------------------------------------------------\n"
    fi   
else
        echo -e "\n------------------------------------------------------------"
        echo -e "[INFO]: MAKE CUT errors could not be validated."
        echo -e "--------------------------------------------------------------\n"
fi

############ RELEASE INSTALLATION ##########          
install_release $RELEASE_CODE