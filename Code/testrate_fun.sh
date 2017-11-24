#!/bin/bash

function testrate {		
	parent=$1
	filename=$2
	rate=`awk -v prev=$3 "BEGIN {print prev+0.05}"`
	method=$4
	method_backbone=$5
	file_type=$6
	num_lines=$7
	func_type="test"
	echo $filename $file_type	
	cd $parent/Sample_Reads
	if [[ ${file_type} == "fastq" ]]; then
		jobid_step1=`sbatch Code/subordinate_for_fastq.sh "Assembly" $filename $rate $num_lines | cut -d ' ' -f 4`
		sleep 5
	elif [[ ${file_type} == "bam" ]]; then
		jobid_step1=`sbatch Code/subordinate.sh "Assembly" $filename $rate | cut -d ' ' -f 4`
		sleep 5
	else
		echo "Broken: $1 $2 $3 $4 $5 $6 $7"
		exit
	fi
	cd $parent/Assembly_Reads	
	jobid_step2=`sbatch --dependency=afterok:$jobid_step1 Code/subordinate.sh "Assembly" $filename $method $method_backbone $parent $func_type | cut -d ' ' -f 4`
	sleep 5
	cd $parent/Alignment_Reads 
	jobid_step3=`sbatch --dependency=afterok:$jobid_step2 Code/subordinate_test.sh "Assembly" $filename $parent | cut -d ' ' -f 4`
	sleep 5
	cd $parent/Quality_Evaluation
	jobid_step4=`sbatch --dependency=afterok:$jobid_step3 Code/subordinate.sh $rate $filename $parent | cut -d ' ' -f 4`	
	sleep 5
	cd $parent
	sbatch --dependency=afterok:$jobid_step4 Code/subordinate.sh $parent $filename $rate $method $method_backbone $file_type $num_lines
	sleep 5
}

function defrate {		
	parent=$1
	filename=$2
	rate=$3
	method=$4
	method_backbone=$5
	func_type="def"
	cd $parent/Sample_Reads
	jobid_step1=`sbatch Code/subordinate.sh "Assembly" $filename $rate | cut -d ' ' -f 4`
	sleep 5
	cd $parent/Assembly_Reads
	jobid_step2=`sbatch --dependency=afterok:$jobid_step1 Code/subordinate.sh "Assembly" $filename $method $method_backbone $parent $func_type | cut -d ' ' -f 4`
	sleep 5
}
