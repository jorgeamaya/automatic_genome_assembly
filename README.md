# Automatic Genome Assembly
*Written by: Jorge Eduardo Amaya Romero*

Read this whole file before using the script

##Description: 
These scripts automatize the assembly of mitochondrial genomes (or small genomes, small genomic regions, etc.) using the programm MITObim\_1.9.pl 

These scripts were designed to run on Slurm Version 16.05 at Peregrine, the HPCC at the University of Groningen. You may have to edit the first lines of the Code/subortdinate\*.sh files found inside each of the following directories so the scripts run on your system. Edit also the Alignment/master.sh. 

Run ./master.sh -h for more info on how tu use the pipeline

##Pipelines and Scripts

1. Sample\_Rates: Performs the subsampling.
2. Assembly\_Rates: Performs the assembly.
3. Alignment\_Rates: Aligns the assemblies.
4. master\_retrive.sh: Retrive the best sampling rates for your samples.

##Results

1. terminated.csv: The best sampling rate for each sample.
2. redo.csv: Samples that did not produce satisfactory assemblies (and some more info on why.)
3. Results/Alignment\_Rates/final\_alignment.fasta: A multiple sequence alignment with the best assembled sequence for each sequence

##Additional Notes
1. I have seen the best results by running the pipeline with the flags -b force\_IUPAC -i standard, i.e., forcing IUPAC concensus when building the backbone and letting the MITObim extended the assembly with ambiguities, but this will depend a lot on your data set. Try and find what is better for you.
2. To force IUPAC concensus in ambiguous calls, the flag fnicpst=yes has been included in the parameters of manifest\_force\_IUPAC.conf as well in MITObim\_force\_IUPAC.pl. 

##Reference
Integrated to this pipeline are the scripts of other people:

* [picard](https://github.com/broadinstitute/picard)
* [MITObim](https://github.com/chrishah/MITObim)
