#!/bin/bash

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape
for i in GBM iPSC NPC NHA;do
	awk 'BEGIN{OFS="\t"} NR>1 {split($1, a, "[:-_]"); $1=a[1]; $2=a[2]; $3=a[3]; $4=a[4]; $5=a[5]; $6=a[6]; print}' \
		${loopdir}/${i}/${i}_loop.bed > \
		./loopbedpe/${i}.tmp
done 


