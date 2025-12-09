#!/bin/bash

source activate ~/miniforge3/envs/juicer
filename=/cluster2/home/futing/Project/panCancer/GBM/GSE185192/NPC/aligned/merged_nodups_medium.txt
coveragename=/cluster2/home/futing/Project/panCancer/GBM/GSE185192/NPC/aligned/50bp.txt

# Create 50bp coverage vector
if [ ! -s $coveragename ]
then
    awk '{
      if ($10>0&&$11>0&&$5!=$9)
        {
        chr1=0;
        chr2=0;

        chr1=$3; 
        chr2=$7;
        if (chr1!=0&&chr2!=0)
        {
         val[chr1 " " int($4/50)*50]++
         val[chr2 " " int($8/50)*50]++
        }
      }
   }
   END{
     for (i in val)
     {
       print i, val[i]
     }
   }' "$filename" > $coveragename
fi
bash /cluster2/home/futing/software/juicer-1.6/misc/calculate_map_resolution.sh \
	$filename $coveragename
