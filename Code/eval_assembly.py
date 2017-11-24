#!/bin/env python

#Description: Writes a series of tables with summary statistics of the assemblies
#Written by: Jorge Eduardo Amaya Romero
#Last time revised: 14-10-2016

from Bio 	import SeqIO
import csv
import sys
import glob
import re
import os
import collections
import itertools
import operator

class AutoVivification(dict):
    """Implementation of perl's autovivification feature."""
    def __getitem__(self, item):
        try:
            return dict.__getitem__(self, item)
        except KeyError:
            value = self[item] = type(self)()
            return value

s = open("Results/Scores.csv", 'w')

rates = []
files=glob.glob("Results/Count*.csv")

for f in glob.glob("Results/Count*.csv"):
	m = re.match(r"Results/Count_(.*)\.csv",f)
        rates.append(m.group(1))

lists=[]
for rate in sorted(rates):
	reader = csv.reader(open("".join(["Results/Count_",rate,".csv"])),delimiter=",")
	for line in reader:
		lists.append([line[0], float(rate), int(line[1])])

data =[]
for k, g in itertools.groupby(sorted(lists, key=operator.itemgetter(0)), key=operator.itemgetter(0)):
	for i in list(g):
		if(str(min(rates)) == str(float(i[1]))):
			data.append([i[0],i[1],i[2]]) 			
		else:
			for line in data:
				if(line[0] == i[0] and line[2] > i[2]):
#				 	print(" ".join(["Update",str(line[0]),"==",str(i[0]),str(line[2]),">",str(i[2])]))
					data.pop()
					data.append([i[0],i[1],i[2]])

try:
	writerg = csv.writer(s)
	for i in data:
		writerg.writerow((i[0], str(i[1]), i[2])) #Print the id and the number of ambiguities
finally:
	s.close()
