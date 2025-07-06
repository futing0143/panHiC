#!/bin/bash


IFS=$','
while read -r gse cell enzyme;do
	gunzip -t /cluster2/home/futing/Project/panCancer/CRC/GSE137188/${cell}/fastq/*
done < "/cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_meta.txt"