#!/bin/bash

# Enable debug mode
# set -x

# Environment variables
export TZ="UTC"
envs="envs:"
IFS=',' read -ra user_array <<< "$USER_NAMES"
IFS=',' read -ra name_array <<< "$NAMES"
sv_password="<password>"

#Starting Script
echo -e "--------------------------------------------------\n Starting at $(date) $(TZ) \n--------------------------------------------------\n" > artifact.txt

# Check the value of the boolean variable
if [ "$DEV_HUB" = true ] || [ "$DEV_OCS" = true ] || [ "$BLD_HUB" = true ] || [ "$TST1_HUB" = true ] || [ "$TST1_OCS" = true ] || [ "$TST2_HUB" = true ] || [ "$TST2_OCS" = true ] || [ "$HAR_HUB" = true ] || [ "$HAR_OCS_KY" = true ] || [ "$HAR_OCS_BB" = true ] || [ "$HAR_OCS_ANT" = true ] || [ "$REF_HUB" = true ] || [ "$TRN_HUB" = true ] || [ "$SIT_HUB" = true ] || [ "$SIT_OCS_KY" = true ] || [ "$SIT_OCS_BB" = true ] || [ "$SIT_OCS_ANT" = true ] || [ "$UAT_HUB" = true ] || [ "$UAT_OCS_KY" = true ] || [ "$UAT_OCS_BB" = true ] || [ "$UAT_OCS_ANT" = true ] || [ "$PRD_HUB" = true ] || [ "$PRD_OCS_KY" = true ] || [ "$PRD_OCS_BB" = true ] || [ "$PRD_OCS_ANT" = true ] || [ "$HAR_OCS_JA" = true ] || [ "$PREPRD_HUB" = true ] || [ "$PREPRD_OCS_KY" = true ] || [ "$PREPRD_OCS_BB" = true ] || [ "$PREPRD_OCS_ANT" = true ] || [ "$MNT_HUB" = true ] || [ "$MNT_OCS_BB" = true ] || [ "$MNT_OCS_ANT" = true ] || [ "$MNT_OCS_KY" = true ] || [ "$DEV_MNT" = true ] || [ "$DEV_MNT_OCS" = true ]|| [ "$BLD_MNT" = true ] || [ "$TST_MNT_HUB" = true ] || [ "$TST_MNT_OCS" = true ] || [ "$REF2_HUB" = true ] || [ "$REF2_OCS" = true ] || [ "$HAR2_HUB" = true ] || [ "$HAR2_OCS_KY" = true ] || [ "$HAR2_OCS_BB" = true ] || [ "$HAR2_OCS_ANT" = true ] || [ "$TST3_HUB" = true ] || [ "$TST3_OCS" = true ] || [ "$PRF_HUB" = true ] || [ "$PRF_OCS" = true ] || [ "$TRN_OCS" = true ] || [ "$TST4_HUB" = true ] || [ "$TST4_OCS" = true ] || [ "$REF3_HUB" = true ] || [ "$REF3_OCS" = true ]; then	
    echo -e "At least one environment has been selected." >> artifact.txt
else
	echo -e "Error: Select at least one environment." >> artifact.txt
	exit 1
fi

# Ensure the number of inputs matches
if [[ ${#user_array[@]} -ne ${#name_array[@]} ]]; then
	echo -e "Error: Number of inputs does not match between -> USER_NAME - NAME" >> artifact.txt
	exit 1 
fi

for i in "${!user_array[@]}"; do
	username="${user_array[$i]}"
	name="${name_array[$i]}"
	envs="envs:"
    set -x
	if [ "$DEV_HUB" = true ]; then    
	
		envs="${envs} DEV_HUB "
		echo -e "DEV_HUB env has been selected." >> artifact.txt
			
            ssh c1dev1b@xx.19.52.xx "
					#!/bin/bash
					#Instance variables
					source ~/.profile > /dev/null
					\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt		
	fi

	if [ "$DEV_OCS" = true ]; then    
	
		envs="${envs} DEV_OCS "
		echo -e "DEV_OCS env has been selected." >> artifact.txt
			    
				ssh -q "c1dev1b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
			
	fi
    
    	if [ "$DEV_MNT" = true ]; then    
	
		envs="${envs} DEV_MNT "
		echo -e "DEV_MNT env has been selected." >> artifact.txt
			    
				ssh -q "c1devm1b@xx.19.52.xx" <<EOF >> artifact.txt

#export RELGEN_USER=relgen; export RELGEN_PASSWD=<password>; LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile DEVELOPER -dbaccess rw -noexpire -relgen -role CSR;
LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile DEVELOPER  -dbaccess rw -noexpire -role CSR;
EOF
			
	fi
    
		if [ "$DEV_MNT_OCS" = true ]; then    
	
		envs="${envs} DEV_MNT_OCS "
		echo -e "DEV_MNT_OCS env has been selected." >> artifact.txt
			    
				ssh -q "c1devmocs1b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
			
	fi

	if [ "$BLD_HUB" = true ]; then    
	
		envs="${envs} BLD_HUB "
		echo -e "BLD_HUB env has been selected." >> artifact.txt
	
            ssh c1bld1b@xx.19.52.xx "
					#!/bin/bash
					#Instance variables
					source ~/.profile > /dev/null
					\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt	

	fi 

	if [ "$TST1_HUB" = true ]; then    
	
		envs="${envs} TST1_HUB "
		echo -e "TST1_HUB env has been selected." >> artifact.txt
			
            ssh c1tst1b@xx.19.52.xx "
					#!/bin/bash
					#Instance variables
					source ~/.profile > /dev/null
					\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt

	fi

	if [ "$TST1_OCS" = true ]; then    
	
		envs="${envs} TST1_OCS "
		echo -e "TST1_OCS env has been selected." >> artifact.txt

			ssh -q "c1tstocs1b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi

	if [ "$TST2_HUB" = true ]; then    
	
		envs="${envs} TST2_HUB "
		echo -e "TST2_HUB env has been selected." >> artifact.txt

            ssh c1tst2b@xx.19.52.xx "
					#!/bin/bash
					#Instance variables
					source ~/.profile > /dev/null
					\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
  
	fi
			
	if [ "$TST2_OCS" = true ]; then    
	
		envs="${envs} TST2_OCS "
		echo -e "TST2_OCS env has been selected." >> artifact.txt

			ssh -q "c1tstocs2b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi
			
	if [ "$HAR_HUB" = true ]; then    
	
		envs="${envs} HAR_HUB "
		echo -e "HAR_HUB env has been selected." >> artifact.txt

            ssh c1har1b@xx.19.52.xx "
					#!/bin/bash
					#Instance variables
					source ~/.profile > /dev/null
					\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt

	fi			
	
	if [ "$HAR_OCS_JA" = true ]; then    
	
		envs="${envs} HAR_OCS_JA "
		echo -e "HAR_OCS_JA env has been selected." >> artifact.txt

			ssh -q "c1harocs1b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi
	
	if [ "$HAR_OCS_KY" = true ]; then    
	
		envs="${envs} HAR_OCS_KY "
		echo -e "HAR_OCS_KY env has been selected." >> artifact.txt

			ssh -q "c1kyhrocs1b@xx.19.111.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi

	if [ "$HAR_OCS_BB" = true ]; then    
	
		envs="${envs} HAR_OCS_BB "
		echo -e "HAR_OCS_BB env has been selected." >> artifact.txt

		ssh -q "c1bbhocs1b@xx.19.112.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi			

	if [ "$HAR_OCS_ANT" = true ]; then    
	
		envs="${envs} HAR_OCS_ANT "
		echo -e "HAR_OCS_ANT env has been selected." >> artifact.txt

		ssh -q "c1auhocs1b@xx.19.114.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi			

	if [ "$REF_HUB" = true ]; then    
	
		envs="${envs} REF_HUB "
		echo -e "REF_HUB env has been selected." >> artifact.txt

		ssh -q "c1ref1b@xx.19.52.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi

	if [ "$TRN_HUB" = true ]; then    
	
		envs="${envs} TRN_HUB "
		echo -e "TRN_HUB env has been selected." >> artifact.txt

		ssh c1trncc1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}

" >> artifact.txt

	fi					
			
	if [ "$SIT_HUB" = true ]; then    
	
		envs="${envs} SIT_HUB  "
		echo -e "SIT_HUB env has been selected." >> artifact.txt

		ssh c1sit1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}

" >> artifact.txt

	fi

	if [ "$SIT_OCS_KY" = true ]; then    
	
		envs="${envs} SIT_OCS_KY "
		echo -e "SIT_OCS_KY env has been selected." >> artifact.txt

		ssh -q "c1kysocs1b@xx.18.141.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi

	if [ "$SIT_OCS_BB" = true ]; then    
	
		envs="${envs} SIT_OCS_BB "
		echo -e "SIT_OCS_BB env has been selected." >> artifact.txt

		ssh -q "c1bbsocs1b@xx.18.38.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi
	
	if [ "$SIT_OCS_ANT" = true ]; then    
	
		envs="${envs} SIT_OCS_ANT "
		echo -e "SIT_OCS_ANT env has been selected." >> artifact.txt

		ssh -q "c1ausocs1b@xx.21.158.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi			

	if [ "$UAT_HUB" = true ]; then    
	
		envs="${envs} UAT_HUB "
		echo -e "UAT_HUB env has been selected." >> artifact.txt

		ssh c1uatu1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}

" >> artifact.txt
 
	fi

	if [ "$UAT_OCS_KY" = true ]; then    
	
		envs="${envs} UAT_OCS_KY "
		echo -e "UAT_OCS_KY env has been selected." >> artifact.txt

		ssh -q "c1kyuocs1b@xx.18.141.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi

	if [ "$UAT_OCS_BB" = true ]; then    
	
		envs="${envs} UAT_OCS_BB "
		echo -e "UAT_OCS_BB env has been selected." >> artifact.txt

		ssh -q "c1bbuocs1b@xx.18.38.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi		

	if [ "$UAT_OCS_ANT" = true ]; then    

		envs="${envs} UAT_OCS_ANT "
		echo -e "$UAT_OCS_ANT env has been selected." >> artifact.txt
 
 		ssh -q "c1auuocs1b@xx.21.158.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi
	
	if [ "$MNT_HUB" = true ]; then    
	
		envs="${envs} MNT_HUB "
		echo -e "MNT_HUB env has been selected." >> artifact.txt
			    
		ssh c1mnt1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}

" >> artifact.txt
			
	fi
	
	if [ "$MNT_OCS_KY" = true ]; then    
	
		envs="${envs} MNT_OCS_KY "
		echo -e "MNT_OCS_KY env has been selected." >> artifact.txt
			    
				ssh -q "c1kymocs1b@xx.19.115.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
			
	fi
    
    if [ "$MNT_OCS_BB" = true ]; then    
	
		envs="${envs} MNT_OCS_BB "
		echo -e "MNT_OCS_BB env has been selected." >> artifact.txt
			    
				ssh -q "c1bbmocs1b@xx.19.124.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
			
	fi	

	if [ "$MNT_OCS_ANT" = true ]; then    
	
		envs="${envs} MNT_OCS_ANT "
		echo -e "MNT_OCS_ANT env has been selected." >> artifact.txt
			    
				ssh -q "c1aumocs1b@xx.19.4.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
			
	fi		
    
	if [ "$PREPRD_HUB" = true ]; then    
	
		envs="${envs} PREPRD_HUB "
		echo -e "PREPRD_HUB env has been selected." >> artifact.txt

		ssh c1pre1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
 
	fi

	if [ "$PREPRD_OCS_KY" = true ]; then    
	
		envs="${envs} PREPRD_OCS_KY "
		echo -e "PREPRD_OCS_KY env has been selected." >> artifact.txt

		ssh -q "c1kyppocs1b@xx.19.115.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi
	
	if [ "$PREPRD_OCS_BB" = true ]; then    
	
		envs="${envs} PREPRD_OCS_BB "
		echo -e "PREPRD_OCS_BB env has been selected." >> artifact.txt

		ssh -q "c1bbppocs1b@xx.19.124.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi
	
	if [ "$PREPRD_OCS_ANT" = true ]; then    
	
		envs="${envs} PREPRD_OCS_ANT "
		echo -e "PREPRD_OCS_ANT env has been selected." >> artifact.txt

		ssh -q "c1auppocs1b@xx.19.4.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
 
	fi
    
	if [ "$PRD_HUB" = true ]; then    
	
		envs="${envs} PRD_HUB "
		echo -e "PRD_HUB env has been selected." >> artifact.txt

		ssh c1prd1b@xx.19.53.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
 
	fi

	if [ "$PRD_OCS_KY" = true ]; then    
	
		envs="${envs} PRD_OCS_KY "
		echo -e "PRD_OCS_KY env has been selected." >> artifact.txt

		ssh -q "c1cypocs1b@xx.19.115.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi			

	if [ "$PRD_OCS_BB" = true ]; then    
	
		envs="${envs} PRD_OCS_BB "
		echo -e "PRD_OCS_BB env has been selected." >> artifact.txt

		ssh -q "c1bbpocs1b@xx.19.124.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF

	fi

	if [ "$PRD_OCS_ANT" = true ]; then    
	
		envs="${envs} PRD_OCS_ANT "
		echo -e "PRD_OCS_ANT env has been selected." >> artifact.txt

		ssh -q "c1aupocs1b@xx.19.4.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi

	if [ "$BLD_MNT" = true ]; then    
	
		envs="${envs} BLD_MNT "
		echo -e "BLD_MNT env has been selected." >> artifact.txt

		ssh c1bld2b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
	
	fi
	
	if [ "$TST_MNT_HUB" = true ]; then    
	
		envs="${envs} TST_MNT_HUB "
		echo -e "TST_MNT_HUB env has been selected." >> artifact.txt

		ssh c1tm1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
	
	fi
    
    if [ "$TST_MNT_OCS" = true ]; then    
	
		envs="${envs} TST_MNT_OCS "
		echo -e "TST_MNT_OCS env has been selected." >> artifact.txt

		ssh -q "c1tmocs1b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
	
	if [ "$REF2_HUB" = true ]; then    
	
		envs="${envs} REF2_HUB "
		echo -e "REF2_HUB env has been selected." >> artifact.txt

		ssh -q "c1ref2b@xx.19.52.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
	
	if [ "$REF2_OCS" = true ]; then    
	
		envs="${envs} REF2_OCS "
		echo -e "REF2_OCS env has been selected." >> artifact.txt

		ssh -q "c1refp1b@xx.19.53.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
    
	if [ "$HAR2_HUB" = true ]; then    
	
		envs="${envs} HAR2_HUB "
		echo -e "HAR2_HUB env has been selected." >> artifact.txt

		ssh c1har2b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
	
	fi
	
	if [ "$HAR2_OCS_KY" = true ]; then    
	
		envs="${envs} HAR2_OCS_KY "
		echo -e "HAR2_OCS_KY env has been selected." >> artifact.txt

		ssh -q "c1kyhocs2b@xx.19.111.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi	

	if [ "$HAR2_OCS_BB" = true ]; then    
	
		envs="${envs} HAR2_OCS_BB "
		echo -e "HAR2_OCS_BB env has been selected." >> artifact.txt

		ssh -q "c1bbhocs2b@xx.19.112.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
	
	if [ "$HAR2_OCS_ANT" = true ]; then    
	
		envs="${envs} HAR2_OCS_ANT "
		echo -e "HAR2_OCS_ANT env has been selected." >> artifact.txt

		ssh -q "c1auhocs2b@xx.19.114.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi	
    
	if [ "$TST3_HUB" = true ]; then    
	
		envs="${envs} TST3_HUB "
		echo -e "TST3_HUB env has been selected." >> artifact.txt

		ssh -q "c1tst3b@xx.19.52.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi	
	
	if [ "$TST3_OCS" = true ]; then    
	
		envs="${envs} TST3_OCS "
		echo -e "TST3_OCS env has been selected." >> artifact.txt

		ssh -q "c1tstocs3b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
	
	if [ "$PRF_HUB" = true ]; then    
	
		envs="${envs} PRF_HUB "
		echo -e "PRF_HUB env has been selected." >> artifact.txt

		ssh c1prf1b@xx.19.52.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
	
	fi
	
	if [ "$PRF_OCS" = true ]; then    
	
		envs="${envs} PRF_OCS "
		echo -e "PRF_OCS env has been selected." >> artifact.txt

		ssh -q "c1prfocs1b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
    
    if [ "$TRN_OCS" = true ]; then    
	
		envs="${envs} TRN_OCS "
		echo -e "TRN_OCS env has been selected." >> artifact.txt

		ssh -q "c1trnce1b@xx.19.52.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR; 

EOF
	
	fi
    
    if [ "$TST4_HUB" = true ]; then    
	
		envs="${envs} TST4_HUB "
		echo -e "TST4_HUB env has been selected." >> artifact.txt

		ssh -q "c1tst4b@xx.19.52.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR;

EOF
	
	fi
    
    if [ "$TST4_OCS" = true ]; then    
	
		envs="${envs} TST4_OCS "
		echo -e "TST4_OCS env has been selected." >> artifact.txt

		ssh -q "c1tstocs4b@xx.19.109.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR; 

EOF
	
	fi

    if [ "$REF3_HUB" = true ]; then    
	
		envs="${envs} REF3_HUB "
		echo -e "REF3_HUB env has been selected." >> artifact.txt

		ssh c1ref3b@xx.19.47.xx "
			#!/bin/bash
			#Instance variables
			source ~/.profile > /dev/null
			\$ATA_HOME/sv_create_user.sh ${username} '${name}' '${sv_password}' ${PROFILE} ${TYPE}
" >> artifact.txt
	
	fi
    
    if [ "$REF3_OCS" = true ]; then    
	
		envs="${envs} REF3_OCS "
		echo -e "REF3_OCS env has been selected." >> artifact.txt

		ssh -q "c1refocs3b@xx.19.47.xx" <<EOF >> artifact.txt

LOGNAME=tpsysadm; create_user -login ${username} -name "${name}" -passwd "${sv_password}" -profile ${PROFILE} -dbaccess rw -noexpire -role CSR; 

EOF
	
	fi
    
echo -e "\nAcccess has been provided to requested ${envs} for username:${username}.\n" >> artifact.txt
set +x  
done

echo -e "--------------------------------------------------\n Ending at $(date) $(TZ). \n--------------------------------------------------\n" >> artifact.txt

# Disable debug mode
#set +x