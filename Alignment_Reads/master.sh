#!/bin/bash

#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --job-name=master_ali
#SBATCH --mem=1Gb
#SBATCH --partition=regular
#SBATCH --out=master%j.log

#Description: Obtain the assemblies and align the sequences to the reference
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge

ln -s ${1}/Assembly_Reads/Results/Assembly/*.tar.gz Data/Assembly/.
sed -i 's/\r$//g' Results/seqs.fasta
sed -i '$ d' Results/seqs.fasta

jobids=()
#The structure of the directories is not regular. Make a list of all the directories that are going to reviewed.
for spe in Data/*; do
	spe="${spe##*/}"
	for path_filename_ext in Data/${spe}/*; do
		path_filename="${path_filename_ext%.tar.gz}"
		filename="${path_filename##*/}"
		cmd="sbatch Code/subordinate_final.sh ${spe} ${filename}"
		jobids+=(`$cmd | cut -d ' ' -f 4`)
		sleep 5
	done
done

jobsnames=$(printf ":%s" "${jobids[@]}")
jobsnames=${jobsnames:1}

sbatch --dependency=afterok:$jobsnames Code/subordinate_paral.sh
