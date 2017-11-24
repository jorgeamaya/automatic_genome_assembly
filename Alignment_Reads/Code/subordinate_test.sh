#!/bin/bash

#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=ali
#SBATCH --mem=5Gb
#SBATCH --partition=short
#SBATCH --output=ali%j.log

#Description: Obtain the last assembly with IUPAC ambiguities
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge
module load MUSCLE/3.8.31-foss-2016a

ln -s ${3}/Assembly_Reads/Results/Assembly/${2}.tar.gz Data/Assembly/.

cd Results
tar -xzvf ../Data/$1/$2\.tar.gz $2/iteration*/$2-AGAM_assembly/$2-AGAM_d_results/$2-AGAM_out_AllStrains.unpadded.fasta
mv $2/iteration*/$2-AGAM_assembly/$2-AGAM_d_results/$2-AGAM_out_AllStrains.unpadded.fasta .
rm -r $2 
awk -v header="${1}_${2}" '/^>/{print ">" header; next}{print}' < ${2}-AGAM_out_AllStrains.unpadded.fasta > ${2}.fasta
rm $2-AGAM_out_AllStrains.unpadded.fasta
cd ../

cp Results/seqs.fasta Results/seqs_${2}.fasta
cat Results/${2}.fasta >> Results/seqs_${2}.fasta
muscle -in Results/seqs_${2}.fasta -out Results/seqs_${2}.afa
