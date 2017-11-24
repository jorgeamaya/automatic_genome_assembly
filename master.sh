#!/bin/bash

#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=master
#SBATCH --mem=1Gb
#SBATCH --output=master%j.log
#SBATCH --partition=regular

#Description: Creates a table with summary statistics of the alignment and the assembly to compare their quality
#Written by: Jorge Eduardo Amaya Romero
#Last time revised: 14-10-2016

name="$(tput bold)NAME$(tput sgr0)
$(basename "$0") -- program that automatize the assembly of mitochondrial genomes (and other small sequences) using MITObim"
	
usage="$(tput bold)USAGE$(tput sgr0)	
$(basename "$0") [-h] -m [test|final|redo] -b [standard|force_IUPAC] -i [standard|force_IUPAC] -d [path/to/data] -r [path/to/reference]

where:
    $(tput bold)-h $(tput sgr0)show this help text
    $(tput bold)-m [test|final|redo]$(tput sgr0) pipeline mode.
	test: test the best sampling rates. 
	final: obtain the final alignment. 
	redo: test the best sampling rates for samples that did not work (you can try more stringent -b and -i flags.)
    $(tput bold)-b [standard|force_IUPAC]$(tput sgr0) specify the methodology that will be used to deal with ambiguities when stablishing the backbone
	standard: allows for ambiguities
	force_IUPAC: forces IUPAC concensus when ambiguities are found
    $(tput bold)-i [standard|force_IUPAC]$(tput sgr0) specify the methodology that will be used to deal with ambiguities during the iterative assembly steps
    	standard: allows for ambiguities
        force_IUPAC: forces IUPAC concensus when ambiguities are found
    $(tput bold)-d $(tput sgr0)address to the directory with bam files
    $(tput bold)-r $(tput sgr0)address to the reference genome
"
while getopts ':hm:b:i:d:r:' option; do
  case "$option" in
    h) echo "$name"
       echo "$usage"
       exit
       	;;
    m) mode=$OPTARG
	;;
    b) method_backbone=$OPTARG
       	;;
    i) method_iteration=$OPTARG
       	;;
    d) path_to_data=$OPTARG
       	;;
    r) path_to_reference=$OPTARG
	;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       	;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

[[ -n $method_backbone ]] || {
	echo "missing -b"
} 

[[ -n $method_iteration ]] || {
	echo "missing -i"
} 

[[ -n $path_to_data ]] || {
	echo "missing -d"
} 

[[ -n $path_to_reference ]] || {
	echo "missing -r"
} 

[[ -n $mode ]] || {
	echo "missing -m"
}

[[ -n $method_backbone ]] || [[ -n $method_iteration ]] || [[ -n $path_to_data ]] || [[ -n $path_to_reference ]] || [[ -n $mode ]] || { 
	echo "$usage" 
	exit 1
}

parent=$PWD

if [[ $mode == "final" || $mode == "redo" ]] && [[ ! -f $parent/terminated.csv ]]; then
	echo "Neither terminated.csv nor redo.csv files found"
	echo "Generating..."
	./master_retrive.sh	
fi

rm -f *.log

cd $parent/Sample_Reads
./clean.sh
mkdir Data
mkdir Results

for path_filename_ext in $path_to_data/*; do
	path_filename="${path_filename_ext%.bam}"
	filename="${path_filename##*/}"
	ln -s ${path_filename_ext} Data/${filename}.bam
done

cd $parent/Assembly_Reads
./clean.sh
mkdir -p Data/Assembly
mkdir Results
ln -s $path_to_reference Data/.

cd $parent/Alignment_Reads
./clean.sh
mkdir -p Data/Assembly
mkdir Results
cp $path_to_reference Results/seqs.fasta
sed -i 's/\r$//g' Results/seqs.fasta
sed -i '$ d' Results/seqs.fasta

cd $parent/Quality_Evaluation
./clean.sh
mkdir Data
mkdir Results 

cd $parent

if [[ $mode == "final" ]]; then
	while IFS='' read -r line || [[ -n "$line" ]]; do	
		filename=`echo $line | cut -d',' -f1`
		rate=`echo $line | cut -d',' -f3`	
		sbatch Code/subordinate_def.sh $parent $filename $rate $method_iteration $method_backbone
		sleep 5
	done < "$parent/terminated.csv"

elif [[ $mode == "redo" ]]; then
	while IFS='' read -r line || [[ -n "$line" ]]; do
		if [[ $line == *"Notterminated"* ]]; then
			echo $line
			filename=`echo "$line" | cut -d',' -f1`
			rate=`echo "$line" | cut -d',' -f4`
			sbatch Code/subordinate.sh $parent $filename $rate $method_iteration $method_backbone "First"
	        sleep 5
		fi
	done < "$parent/redo.csv"

elif [[ $mode == "test" ]]; then
	rm -f *.csv
	for path_filename_ext in Sample_Reads/Data/*; do
		if [[ ${path_filename_ext##*.} ==  "bam" ]]; then	
			filename_ext=${path_filename_ext##*/}
			filename=${filename_ext%.bam}
			echo $filename
			sbatch Code/subordinate_test.sh $parent $filename 0 $method_iteration $method_backbone "bam" "-" "First"
			sleep 5
		fi
	done
fi
