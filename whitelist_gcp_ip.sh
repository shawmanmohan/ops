#!/bin/bash 

digtxtarray=()
for LINE in `dig txt @8.8.8.8 _cloud-netblocks.googleusercontent.com +short | tr " " "\n" | grep include | cut -f 2 -d :`
do
	digtxtarray+=($LINE)
	for LINE2 in `dig txt @8.8.8 $LINE +short | tr " " "\n" | grep include | cut -f 2 -d :`
	do
		digtxtarray+=($LINE2)
	done
done 

for LINE in ${digtxtarray[@]}
do
	dig txt $LINE +short | tr " " "\n" 
done | grep ip4 | cut -f 2 -d : | sort -n +0 +1 +2 +3 -t . > gcp_ip.txt

while read ip; do
aws ec2 authorize-security-group-ingress \
    --group-id sg-0b93befbd8b29c76d \
    --protocol tcp \
    --port 443 \
    --cidr $ip --profile hr-perf
done < gcp_ip.txt