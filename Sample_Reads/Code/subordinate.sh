#!/bin/bash

#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --job-name=bam
#SBATCH --mem=10GB
#SBATCH --output=bam%j.log

#Description: Subset the *.fastq.gz files
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge
module load SAMtools/1.3.1-foss-2016a
module load Python/2.7.11-foss-2016a
module load picard/2.13.2-Java-1.8.0_121
module load Java/1.8.0_92

echo "REGULAR"
spe=$1
sample=$2
rate=$3
echo $spe $sample $rate

# Prepare a directory in /local
mkdir -p Results/${spe}
cd ${TMPDIR}
ln -s ${SLURM_SUBMIT_DIR}/Data
ln -s ${SLURM_SUBMIT_DIR}/Code

echo "Data/${sample}"
mkdir -p Results/${spe}/${sample}

samtools view -s ${rate} -h -o Results/${spe}/${sample}/${sample}\.bam Data/${sample}\.bam
samtools sort -n -o Results/${spe}/${sample}/mit_mapped_norm.qsort.bam Results/${spe}/${sample}/${sample}\.bam
rm -f Results/${spe}/${sample}/${sample}\.bam

# Create the fastq and fastq2 files
java -jar $EBROOTPICARD/picard.jar SamToFastq I=Results/${spe}/${sample}/mit_mapped_norm.qsort.bam FASTQ=Results/${spe}/${sample}/mit_mapped_norm.fq SECOND_END_FASTQ=Results/${spe}/${sample}/mit_mapped_norm.fq2
rm -f Results/${spe}/${sample}/mit_mapped_norm.qsort.bam

# Create the interleaved file
Code/interleave-fastqgz-MITOBIM.py Results/${spe}/${sample}/mit_mapped_norm.fq Results/${spe}/${sample}/mit_mapped_norm.fq2 > Results/${spe}/${sample}/reads.fastq

GZIP=-9 tar cvzf ${sample}.tar.gz Results/${spe}/${sample}
cp ${sample}.tar.gz ${SLURM_SUBMIT_DIR}/Results/${spe}/.
