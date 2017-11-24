#!/bin/bash

parent=$PWD

rm -f *.csv
rm -f *.log
cd $parent/Sample_Reads
./clean.sh
cd $parent/Assembly_Reads
./clean.sh
cd $parent/Alignment_Reads
./clean.sh
cd $parent/Quality_Evaluation
./clean.sh
exit 1
