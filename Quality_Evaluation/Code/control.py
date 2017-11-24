#!/bin/env python

#Description: Writes a series of tables with summary statistics of the assemblies
#Written by: Jorge Eduardo Amaya Romero
#Last time revised: 14-10-2016

from Bio 	import SeqIO
from Bio	import pairwise2
import itertools
import csv
import sys
from Bio.Seq	import MutableSeq
import os

#Function to find control
def findcontrol(seq,end):
	count = seq.count("A",start=0,end=end) + seq.count("G",start=0,end=end) + seq.count("C",start=0,end=end) + seq.count("T",start=0,end=end)
	if count == 14844: #Length of the reference sequence without control region (Refurbish: Change this value to fit your reference)
		return end
	else:
		end += 1
		return findcontrol(seq,end)
	
records = [] #Load and separate the reference from the other sequences
for record in SeqIO.parse(file(sys.argv[1]), "fasta"):
	if record.id == "gi|309056|gb|L20934.1|MSQMTCG": #(Refurbish: Change the name to fit your reference)
		reference = record
	else:
		records.append(record)

print len(reference.seq)
sys.setrecursionlimit(len(reference.seq))
coding_seq = findcontrol(reference.seq,14844) #Length of the reference sequence without control region (Refurbish: Change this value to fit your reference)

path_to_file="".join(["Results/Count_",sys.argv[2],'.csv'])
print(path_to_file)
g = open(path_to_file, 'a')
#writerg = csv.writer(g, lineterminator="\n")
for record in records:
	seq = record.seq[0:coding_seq]
	count = seq.count("A") + seq.count("G") + seq.count("C") + seq.count("T") + seq.count("-")
	if len(record.seq) > count: #Print the result only if the length of the total sequence is larger than the whole assembly, which is true given that the reference includes the d-loop
		print "Coding Seq " + str(coding_seq) + " Len " + str(len(seq)) + " Count " + str(count)
		print >> g, ",".join([record.id,str(len(seq) - count)])
#		writerg.writerow((record.id,len(seq) - count)) #Print the id and the number of ambiguities	
g.close()
