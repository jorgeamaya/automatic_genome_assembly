#!/bin/bash

#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --job-name=ass
#SBATCH --mem=10GB
#SBATCH --output=ass%j.log

#Description: Perform the assembly
#Written by: Jorge Eduardo Amaya Romero
#Last revision: 14-10-2016

module purge
module load SAMtools/1.3.1-foss-2016a
module load Perl/5.22.1-foss-2016a
module load Python/3.5.1-intel-2016a
module load MIRA/4.0.2-foss-2016a-Python-2.7.11

spe=$1
sample=$2
method_iteration=$3
method_backbone=$4
func_type=$6
parent=$PWD
slave=$TMPDIR

ln -s $5/Sample_Reads/Results/Assembly/${sample}.tar.gz Data/Assembly/.

echo "Data/${spe}/${sample}"
mkdir -p Results/${spe}
cd $slave
mkdir $sample
cd $sample

#Get necessary files
tar -xzvf $parent/Data/${spe}/${sample}.tar.gz --strip-components 3
ln -s $parent/Data/AGAMB_MTgenome.fasta reference.fa

#Run Mira and MITObim
cp $parent/Code/manifest_${method_backbone}.conf .
cp $parent/Code/MITObim_${method_iteration}.pl .

sed -i "20s/.*/strain = ${sample}/g" manifest_${method_backbone}.conf

mira manifest_${method_backbone}.conf &> mira_log

if grep -q "Failure, wrapped MIRA process aborted." mira_log; then
	cd $parent
	echo "Aborted due to MIRA fail: Failure, wrapped MIRA process aborted."
else
	perl MITObim_${method_iteration}.pl -start 1 -end 20 -sample ${sample} -ref AGAM -readpool reads.fastq -maf initial-mapping_assembly/initial-mapping_d_results/initial-mapping_out.maf --paired --pair --clean --trimoverhang &> log

	#Remove unnecesary files
	rm reads.fastq mit_mapped_norm.fq mit_mapped_norm.fq2 manifest_${method_backbone}.conf reference.fa MITObim_${method_iteration}.pl
	rm -r initial-mapping_assembly
	if grep -q "your readpool does not contain any reads with reasonable match" log; then
		cd $parent
		echo "Aborted due to MITObim fail: your readpool does not contain any reads with reasonable match."
	else
		ARR=($(ls -d -v -r iteration*))
		rm -r ${ARR[1]}/
		rm -r iteration*/*-AGAM_assembly/*-AGAM_d_tmp
		rm -r iteration*/*-AGAM_assembly/*-AGAM_d_chkpt

		cd ../
		GZIP=-9 tar cvzf ${sample}.tar.gz $sample && rm $sample
		cp ${sample}.tar.gz $parent/Results/${spe}/.
		cd $parent
	fi
fi

if [ $func_type == "def" ]; then
	processes=`squeue -u $USER | grep -c -E "${USER}\s+R"`
	if [ $processes == 1 ]; then
		echo "Last one -- Start aligning"
		cd $5/Alignment_Reads
		sbatch master.sh $5
	fi
fi

sleep 1
