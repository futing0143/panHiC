#!/bin/bash
file=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/BL/GSE294862_gene_matrix_count.csv

head -n1 $file | tr ',' '\n' | xargs -I {} basename {} Aligned.sortedByCoord.out.bam > header.xt

echo -e "Geneid,CA46_1,CA46_2,RAJI_2,RAJI_1" > BL_gene_count.csv
tail -n +2 $file | cut -f1,4,8,22,24 -d ',' >> BL_gene_count.csv
echo -e "Geneid,HB_913613,HB_913615,HB_913614" > HumanBcell_gene_count.csv
tail -n +2 $file | cut -f1,9,12,13 -d ',' >> HumanBcell_gene_count.csv