#!/bin/bash

#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --job-name=rerun
#SBATCH --mem=100
#SBATCH --output=bam%j.log
#SBATCH --partition=short

#Description: Subset the *.fastq.gz files
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge

source ./Code/testrate_fun.sh

echo "testrate $1 $2 $3 $4 $5 $6 $7"
if [[ ${8} == "First" ]]; then
	testrate $1 $2 $3 $4 $5 $6 $7
else
	if [[ ${3} != 1 ]]; then
		if grep -q "Assembly_${2}" Quality_Evaluation/Results/Count_${3}.csv; then
			line=`grep "Assembly_${2}" Quality_Evaluation/Results/Count_${3}.csv | cut -d',' -f2`
			line=$((line))
			if [[ $line -ne 0 ]]; then
				testrate $1 $2 $3 $4 $5 $6 $7
			else
				echo "Successful assembly for $2 at a rate $3"
			fi
		else
			testrate $1 $2 $3 $4 $5 $6 $7
		fi
	fi
fi
