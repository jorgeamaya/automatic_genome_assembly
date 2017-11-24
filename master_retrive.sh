#!/bin/bash

#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=remove
#SBATCH --mem=1Gb
#SBATCH --output=rem.log

module purge
module load Python/2.7.12-foss-2016a

parent=$PWD
python Code/retrieve_rate.py $parent
