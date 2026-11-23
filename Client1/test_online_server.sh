#!/bin/bash

# Environment variables
export TZ="UTC"
time_max=30
offline=0
# Function
test_vms() {

local server=("$1")  
         
timeout ${time_max} ssh -q "corp@$server" <<EOF
	echo "Successful ENV:$envs Server:${server}"
EOF

ret=$?
echo "${ret}"

if [ ${ret} -eq 124 ]; then
    echo "Timed out ENV:$envs Server:${server}" >> Result.txt
    offline=$((offline+1))
fi

}

echo -e "--------------------------------------------------\n Starting at $(date) $(TZ) \n--------------------------------------------------\n" > Result.txt

envs="DEV_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"
done

envs="$DEV_OCS"
IFS=',' read -ra server_array <<< "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
	
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
   
envs="DEV_MNT"
IFS=',' read -ra server_array <<< "xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="DEV_MNT_OCS"
IFS=',' read -ra server_array <<< "xx.19.109.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="BLD_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="TST1_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="TST1_OCS"
IFS=',' read -ra server_array <<< "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="TST2_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="TST2_OCS"
IFS=',' read -ra server_array <<< "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
		
envs="HAR_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="HAR_OCS_KY"
IFS=',' read -ra server_array <<< "xx.19.111.xx,xx.19.111.xx,xx.19.111.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="HAR_OCS_BB"
IFS=',' read -ra server_array <<< "xx.19.112.xx,xx.19.112.xx,xx.19.112.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
2
envs="HAR_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.19.114.xx,xx.19.114.xx,xx.19.114.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="REF_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="HAR2HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="HAR2_OCS_KY"
IFS=',' read -ra server_array <<< "xx.19.111.xx,xx.19.111.xx,xx.19.111.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="HAR2_OCS_BB"
IFS=',' read -ra server_array <<< "xx.19.112.xx,xx.19.112.xx,xx.19.112.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done 

envs="HAR2_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.19.114.xx,xx.19.114.xx,xx.19.114.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done 
	
envs="TRN_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="SIT_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="SIT_OCS_KY"
IFS=',' read -ra server_array <<< "xx.18.141.xx,xx.18.141.xx,xx.18.141.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="SIT_OCS_BB"
IFS=',' read -ra server_array <<< "xx.18.38.xx,xx.18.38.xx,xx.18.38.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="SIT_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.21.158.xx,xx.21.158.xx,xx.21.158.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
			
envs="UAT_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="UAT_OCS_KY"
IFS=',' read -ra server_array <<< "xx.18.141.xx,xx.18.141.xx,xx.18.141.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="UAT_OCS_BB"
IFS=',' read -ra server_array <<< "xx.18.38.xx,xx.18.38.xx,xx.18.38.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="UAT_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.21.158.xx,xx.21.158.xx,xx.21.158.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
    
envs="MNT_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="MNT_OCS_KY"
IFS=',' read -ra server_array <<< "xx.19.115.xx,xx.19.115.xx,xx.19.115.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
  
envs="MNT_OCS_BB"
IFS=',' read -ra server_array <<< "xx.19.124.xx,xx.19.124.xx,xx.19.124.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="MNT_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.19.4.xx,xx.19.4.xx,xx.19.4.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="PREPRD_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="PREPRD_OCS_KY"
IFS=',' read -ra server_array <<< "xx.19.115.xx,xx.19.115.xx,xx.19.115.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="PREPRD_OCS_BB"
IFS=',' read -ra server_array <<< "xx.19.124.xx,xx.19.124.xx,xx.19.124.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	 	
envs="PREPRD_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.19.4.xx,xx.19.4.xx,xx.19.4.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="PRD_HUB"
IFS=',' read -ra server_array <<< "xx.19.53.xx,xx.19.53.xx,xx.19.53.xx,xx.19.53.xx,xx.19.53.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
		
envs="PRD_OCS_KY"
IFS=',' read -ra server_array <<< "xx.19.115.xx,xx.19.115.xx,xx.19.115.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="PRD_OCS_BB"
IFS=',' read -ra server_array <<< "xx.19.124.xx,xx.19.124.xx,xx.19.124.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  
	
envs="PRD_OCS_ANT"
IFS=',' read -ra server_array <<< "xx.19.4.xx,xx.19.4.xx,xx.19.4.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="BLD_MNT"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="TST_MNT_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="TST_MNT_OCS"
IFS=',' read -ra server_array <<< "xx.19.109.xx,xx.19.109.xx,xx.19.109.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done 

envs="TST3_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done  

envs="TST3_OCS"
IFS=',' read -ra server_array <<< "xx.19.109.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done

envs="REF2_HUB"
IFS=',' read -ra server_array <<< "xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done

envs="REF2_OCS"
IFS=',' read -ra server_array <<< "xx.19.53.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done

envs="TRN_OCS"
IFS=',' read -ra server_array <<< "xx.19.52.xx,xx.19.52.xx,xx.19.52.xx"
for i in "${!server_array[@]}"; do
	server="${server_array[$i]}"
	test_vms "${server}"		
done

echo -e "Number of servers that were not reached: $offline \n" >> Result.txt
echo -e "--------------------------------------------------\n Ending at $(date) $(TZ). \n--------------------------------------------------\n" >> Result.txt

if [ ${offline} -eq 0 ]; then
    echo "Didnt send email" >> Result.txt
else
	echo -e "Hi PE Team,\n \nNumber of servers that were not reached: $offline. \nCompleted report has been attached" | mail -a /c1/c1_app/jenkins/workspace/VMsOnline/Result.txt -s "Client1 - CLIENT1 SERVERS AVAILABILITY TEST" List-GLB-Client1-SV-ES@company.com
fi

