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

echo "testrate $1 $2 $3 $4 $5"
defrate $1 $2 $3 $4 $5
