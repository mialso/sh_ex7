#!/bin/bash

declare -a parents
top[1]=0
top[2]=0
top[3]=0
top_id[1]=0
top_id[2]=0
top_id[3]=0
declare -a process
tmpid=0
p_id=0
parents[$tmpid]=0

IFS=$'\n'
for line in $(ps -eo ppid,pid --sort ppid --no-headers); do
	IFS=$' '
	read -a process <<< "$line"
	p_id=${process[0]}

	if ((tmpid == 0)); then
		tmpid=$p_id
	fi
		
	if ((tmpid == p_id)); then
		parents[$p_id]=$[${parents[p_id]}+1]
	else 
		if ((top[1] < parents[tmpid])); then
			top[3]=${top[2]}
			top[2]=${top[1]}
			top[1]=${parents[tmpid]}
			top_id[3]=${top_id[2]}
			top_id[2]=${top_id[1]}
			top_id[1]=$tmpid
		elif ((top[2] < parents[tmpid])); then
			top[3]=${top[2]}
			top[2]=${parents[tmpid]}
			top_id[3]=${top_id[2]}
			top_id[2]=$tmpid
		elif ((top[3] < parents[tmpid])); then
			top[3]=${parents[tmpid]}
			top_id[3]=$tmpid
		fi
		parents[$p_id]=1
		tmpid=$p_id
	fi

done

#for key in ${!parents[@]}; do
#	echo ${key} ${parents[key]}
#done
for key in ${!top_id[@]}; do
	echo parent pid=${top_id[key]}
	echo children:
	ps --ppid ${top_id[key]} -o pid --no-headers
done

