#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --job-name=bam
#SBATCH --mem=10GB
#SBATCH --output=fastq%j.log

#Description: Subset the *.fastq.gz files
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016
#Additional notes: Process the file names of Epiroticus and Christyi

module purge
module load Python/2.7.11-foss-2016a

echo "FOR_FASTQ"
spe=$1
sample=$2
rate=$3
num_lines=$4
echo $spe $sample $rate $num_lines
# Prepare a workdir on /local
mkdir -p Results/${spe}
cd ${TMPDIR}
ln -s ${SLURM_SUBMIT_DIR}/Data
ln -s ${SLURM_SUBMIT_DIR}/Code

echo "Data/${sample}"
mkdir -p Results/${spe}/${sample}

num=`awk -v lines="${num_lines}" -v rate="${rate}" 'BEGIN {print int(lines*rate)}'`
num=$((($num/4)*4))

zcat Data/${sample}.read1.fastq.gz | head -n $num > Results/${spe}/${sample}/mit_mapped_norm.fastq 
zcat Data/${sample}.read2.fastq.gz | head -n $num > Results/${spe}/${sample}/mit_mapped_norm.fastq2 

# Create the interleaved file
	#Indicate from which file the read was extracted by adding /1 or /2 to its end
cat Results/${spe}/${sample}/mit_mapped_norm.fastq | awk '{print (NR%2 == 1) ? $0"/1" : $0}' > Results/${spe}/${sample}/mit_mapped_norm2.fastq
cat Results/${spe}/${sample}/mit_mapped_norm.fastq2 | awk '{print (NR%2 == 1) ? $0"/2" : $0}' > Results/${spe}/${sample}/mit_mapped_norm2.fastq2
rm Results/${spe}/${sample}/mit_mapped_norm.fastq Results/${spe}/${sample}/mit_mapped_norm.fastq2
	#Simplify every third line of the fastq with "+"
#cat Results/$1/samples/$2/mit_mapped_norm2.fastq | awk '{print (NR%4 == 3) ? "+" : $0}' > Results/$1/samples/$2/mit_mapped_norm3.fastq
#cat Results/$1/samples/$2/mit_mapped_norm2.fastq2 | awk '{print (NR%4 == 3) ? "+" : $0}' > Results/$1/samples/$2/mit_mapped_norm3.fastq2
#rm Results/$1/samples/$2/mit_mapped_norm2.fastq Results/$1/samples/$2/mit_mapped_norm2.fastq2
	#Eliminate the  white spaces of the header
cat Results/${spe}/${sample}/mit_mapped_norm2.fastq | awk '{print (NR%4 == 1) ? $1 $2 $3 : $0}' > Results/${spe}/${sample}/mit_mapped_norm4.fastq
cat Results/${spe}/${sample}/mit_mapped_norm2.fastq2 | awk '{print (NR%4 == 1) ? $1 $2 $3 : $0}' > Results/${spe}/${sample}/mit_mapped_norm4.fastq2
rm Results/${spe}/${sample}/mit_mapped_norm2.fastq Results/${spe}/${sample}/mit_mapped_norm2.fastq2

mv Results/${spe}/${sample}/mit_mapped_norm4.fastq Results/${spe}/${sample}/mit_mapped_norm.fastq
mv Results/${spe}/${sample}/mit_mapped_norm4.fastq2 Results/${spe}/${sample}/mit_mapped_norm.fastq2

Code/interleave-fastqgz-MITOBIM.py Results/${spe}/${sample}/mit_mapped_norm.fastq Results/${spe}/${sample}/mit_mapped_norm.fastq2 > Results/${spe}/${sample}/reads.fastq

GZIP=-9 tar cvzf ${sample}.tar.gz Results/${spe}/${sample}
cp ${sample}.tar.gz ${SLURM_SUBMIT_DIR}/Results/${spe}/.

sleep 1
