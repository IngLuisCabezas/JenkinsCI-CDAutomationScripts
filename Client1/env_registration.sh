#!/bin/bash

#Enable debug mode
set -x

#Environment variables
export TZ="UTC"
time_max=30

#IFS=',' read -ra sv_envs <<< "c1har2b@xx.19.52.xx,c1kyhocs2b@xx.19.111.xx,c1bbhocs2b@xx.19.112.xx,c1auhocs2b@xx.19.114.xx,c1tmocs1b@xx.19.109.xx,c1tm1b@xx.19.52.xx,c1bld2b@xx.19.52.xx,c1dev1b@xx.19.52.xx,c1dev1b@xx.19.109.xx,c1devm1b@xx.19.52.xx,c1devmocs1b@xx.19.109.xx,c1bld1b@xx.19.52.xx,c1tst1b@xx.19.52.xx,c1tstocs1b@xx.19.109.xx,c1tst2b@xx.19.52.xx,c1tstocs2b@xx.19.109.xx,c1har1b@xx.19.52.xx,c1harocs1b@xx.19.109.xx,c1kyhrocs1b@xx.19.111.xx,c1bbhocs1b@xx.19.112.xx,c1auhocs1b@xx.19.114.xx,c1ref1b@xx.19.52.xx,c1trncc1b@xx.19.52.xx,c1trnce1b@xx.19.52.xx,c1sit1b@xx.19.52.xx,c1kysocs1b@xx.18.141.xx,c1bbsocs1b@xx.18.38.xx,c1ausocs1b@xx.21.158.xx,c1uatu1b@xx.19.52.xx,c1kyuocs1b@xx.18.141.xx,c1bbuocs1b@xx.18.38.xx,c1auuocs1b@xx.21.158.xx,c1mnt1b@xx.19.52.xx,c1kymocs1b@xx.19.115.xx,c1bbmocs1b@xx.19.124.xx,c1aumocs1b@xx.19.4.xx,c1pre1b@xx.19.52.xx,c1kyppocs1b@xx.19.115.xx,c1bbppocs1b@xx.19.124.xx,c1auppocs1b@xx.19.4.xx,c1prd1b@xx.19.53.xx,c1cypocs1b@xx.19.115.xx,c1bbpocs1b@xx.19.124.xx,c1aupocs1b@xx.19.4.xx"
IFS=',' read -ra sv_envs <<< "c1dev1b@xx.19.52.xx,c1dev1b@xx.19.109.xx,c1devm1b@xx.19.52.xx,c1devmocs1b@xx.19.109.xx,c1bld1b@xx.19.52.xx,c1bld2b@xx.19.52.xx,c1tm1b@xx.19.52.xx,c1tmocs1b@xx.19.109.xx,c1tst1b@xx.19.52.xx,c1tstocs1b@xx.19.109.xx,c1tst2b@xx.19.52.xx,c1tstocs2b@xx.19.109.xx,c1tst3b@xx.19.52.xx,c1tstocs3b@xx.19.109.xx,c1har1b@xx.19.52.xx,c1harocs1b@xx.19.109.xx,c1kyhrocs1b@xx.19.111.xx,c1bbhocs1b@xx.19.112.xx,c1auhocs1b@xx.19.114.xx,c1har2b@xx.19.52.xx,c1kyhocs2b@xx.19.111.xx,c1bbhocs2b@xx.19.112.xx,c1auhocs2b@xx.19.114.xx,c1ref1b@xx.19.52.xx,c1ref2b@xx.19.52.xx,c1refp1b@xx.19.53.xx,c1mnt1b@xx.19.52.xx,c1kymocs1b@xx.19.111.xx,c1bbmocs1b@xx.19.112.xx,c1aumocs1b@xx.19.4.xx,c1trncc1b@xx.19.52.xx,c1trnce1b@xx.19.52.xx,c1sit1b@xx.19.52.xx,c1kysocs1b@xx.18.141.xx,c1bbsocs1b@xx.18.38.xx,c1ausocs1b@xx.21.158.xx,c1uatu1b@xx.19.52.xx,c1kyuocs1b@xx.18.141.xx,c1bbuocs1b@xx.18.38.xx,c1auuocs1b@xx.21.158.xx,c1prf1b@xx.19.52.xx,c1prfocs1b@xx.19.109.xx,c1pre1b@xx.19.52.xx,c1kyppocs1b@xx.19.115.xx,c1bbppocs1b@xx.19.124.xx,c1auppocs1b@xx.19.4.xx,c1prd1b@xx.19.53.xx,c1cypocs1b@xx.19.115.xx,c1bbpocs1b@xx.19.124.xx,c1aupocs1b@xx.19.4.xx"

# Declare an array to store xml env files
declare -a file_names

#Starting Scrtip
echo -e "--------------------------------------------------\n Starting at $(date) $(TZ) \n--------------------------------------------------\n" >  $WORKSPACE/artifact.txt

echo -e "Singleview Environment Register Task" >>  $WORKSPACE/artifact.txt
echo -e "\n" >>  $WORKSPACE/artifact.txt

mkdir sv_xml_files
cd sv_xml_files
#rm -rf *.xml

for i in "${!sv_envs[@]}"; do
	svconnect="${sv_envs[$i]}"
    
	ssh -o ConnectTimeout=$time_max ${svconnect} <<EOF
 		source ~/.profile > /dev/null
 	 	SV_WORKSPACE="/c1/\$ATA_USER/work/jenkins/workspace"
        date=`date "+%Y%m%d%H%M%S"`
        cd \$SV_WORKSPACE
        register_environment -f \$ATA_USER\$date.xml
  		file=\$(find \$SV_WORKSPACE -type f -name "\$ATA_USER\$date.xml" | head -n 1) 
    	echo \$file
    	# return *.xml file
		if [ -n "\$file"  ]; then
			echo "file found"
        	scp "\$file" c1_app@xx.19.52.xx:/data/c1_app/jenkins/workspace/SV_EnvRegister/sv_xml_files
		else
        	echo "no file found "
		fi
EOF
done

file_count=$(ls -1 "$WORKSPACE/sv_xml_files" | wc -l)
echo "Total number of xml env files: $file_count" >>  $WORKSPACE/artifact.txt
echo -e "\n" >>  $WORKSPACE/artifact.txt

file_names=("$WORKSPACE/sv_xml_files"/*)

for fn in "${!file_names[@]}"; do
	echo "File: ${file_names[$fn]}" >>  $WORKSPACE/artifact.txt
    echo "SV env on Client1 FN$((fn+1)) ${file_names[$fn]}"  | mail -a ${file_names[$fn]} -s "Register Client1 Env FN$((fn+1))" sv-env-register@company.com user01@company.com
    sleep 10
done

echo -e "\n" >>  $WORKSPACE/artifact.txt

#Ending Scrtip
echo -e "--------------------------------------------------\n Ending at $(date) $(TZ) \n--------------------------------------------------\n" >>  $WORKSPACE/artifact.txt

# Disable debug mode
set +x
