#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=ali_final
#SBATCH --mem=10Gb
#SBATCH --output=ali_final%j.log
#SBATCH --partition=regular

#Description: Obtain the assemblies and align the sequences to the reference
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge
module load MUSCLE/3.8.31-foss-2016a

for i in Results/*; do
		if [ "Results/seqs.fasta" != ${i} ]; then
	                cat ${i} >> Results/seqs.fasta
		fi
        done

muscle -in Results/seqs.fasta -out Results/final_alignment.fasta
