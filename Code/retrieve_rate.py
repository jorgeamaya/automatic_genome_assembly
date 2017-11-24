#!/bin/env python

import itertools
import sys
import os
from os import listdir
from os.path import isfile, join

count_record = {} #{rate : {name : count }
state = {} #{sample : rate}

def find_best(evaluated_rates, count_record, end):	
	progress = {}
	for rate in evaluated_rates:
		if sample in count_record[rate]:
			progress[rate] = count_record[rate][sample]
		else:
			break
	progression = [ progress[rate] for rate in sorted(progress.keys())]
	if 0.0 in progression:			
		index = [i for i,x in enumerate(progression) if x == 0.0]
		print "Posterior", sample, index[0], sorted(progress.keys())[index[0]]
		print >> terminated, ",".join([sample,"Posterior",str(sorted(progress.keys())[index[0]])])
	else:
		index = progression.index(min(progression))
		pattern = "reduction"
		for i in range(1, len(progression) - 1):
			if pattern == "reduction" and progression[i-1] >= progression[i]:
				pattern = "reduction"
			elif pattern == "reduction" and progression[i-1] < progression[i]:
				pattern = "increase"
			elif pattern == "increase" and progression[i-1] <= progression[i]:
				pattern ="increase"
			elif pattern == "increase" and progression[i-1] > progression[i]:
				pattern = "fluctuation"						
				break	
		print "Notterminated", sample, pattern, sorted(progress.keys())[index]
		if end:
			print >> terminated, ",".join([sample,"Best",str(sorted(progress.keys())[index])])			
		else:
			print >> redo, ",".join([sample,"Notterminated",pattern,str(sorted(progress.keys())[index]),str(min(progression))])			
evaluated_files = sorted([f[:-4] for f in listdir("Sample_Reads/Data/") if isfile(join("Sample_Reads/Data/", f))])
evaluated_rates = sorted([float(f[6:-4]) for f in listdir("Quality_Evaluation/Results/") if isfile(join("Quality_Evaluation/Results/", f))])

#Collect information about the number of ambiguities at each sampling rate for each sample
end = 0
for rate in evaluated_rates:
	count_record[rate] = {}
	if rate == 1.0:	
		file_id = "".join(["Quality_Evaluation/Results/Count_",str(1),".csv"])
		end = 1
	else:
		file_id = "".join(["Quality_Evaluation/Results/Count_",str(rate),".csv"])
	for line in open(file_id):
		line=line.split(",")
		count_record[rate][line[0][9:]] = float(line[1].rstrip())

#Determine if the sample assembled (even with errors) using the smallest sample size ("Early"), at a larger sampling rate ("rate"), or is missing from the batch ("Missing")
for sample in evaluated_files:
	if sample in count_record[0.05]: 
		state[sample] = "Early"
	else:
		for rate in evaluated_rates[1:]:	
			if sample in count_record[rate]: 
				state[sample] = rate
				break
			elif sample not in count_record[rate] and rate == evaluated_rates[-1]:
				state[sample] = "Missing"

terminated = open("terminated.csv", "w")
redo = open("redo.csv", "w")

for sample in state:
	if state[sample] == "Missing": #Sent to the redo file the samples that are missing.
		print "Missing", sample, 0
		print >> redo, ",".join([sample,"Missing",str(0.0)])
	elif state[sample] == "Early": #For samples that assembled "Early"
		if count_record[0.05][sample] == 0:
			print "Early - First", sample, 0.05 #Sent to the terminated file those that assembled at the smallest rate
			print >> terminated, ",".join([sample,"First",str(0.05)])
		else:
			find_best(evaluated_rates, count_record, end) #Sort between the terminated and redo files those samples that produced 0 ambiguities and the redo file those that assembled but still contain ambiguities.
	else: #For samples that starting assembling at certain rate
		rate = state[sample]
		tmp_list = [i for i in evaluated_rates if i >= rate]
		find_best(tmp_list, count_record, end)#Sort between the terminated and redo files those samples that produced 0 ambiguities and the redo file those that assembled but still contain ambiguities.
redo.close()
terminated.close()
