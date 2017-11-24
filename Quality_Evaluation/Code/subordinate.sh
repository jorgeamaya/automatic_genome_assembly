#!/bin/bash

#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=eval
#SBATCH --mem=1Gb
#SBATCH --partition=short
#SBATCH --out=eval%j.log

#Description: Obtain the quality of the alignment
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge
module load Biopython/1.65-foss-2016a-Python-2.7.11

ln -s ${3}/Alignment_Reads/Results/seqs_${2}.afa Data/.
lines=`grep ">" Data/seqs_${2}.afa | wc -l`
lines=$((lines))
if [[ $lines == 2 ]]; then python Code/control.py Data/seqs_${2}.afa $1; fi
