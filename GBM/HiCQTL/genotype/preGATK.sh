#!/bin/bash


# cd /cluster/home/futing/ref_genome/hg38_primary_assembly/bwa
cd /cluster/home/futing/ref_genome/hg38_primary_assembly/jialu/
gatk CreateSequenceDictionary R=hg38.fa \
	O=hg38.dict
gatk ScatterIntervalsByNs R=hg38.fa \
	OT=ACGT N=500 O=hg38.interval_list