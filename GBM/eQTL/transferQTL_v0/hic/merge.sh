#!/bin/bash
work_dir="/cluster/home/futing/Project/GBM/eqtl"
output="merged_with_count.txt"
head -n 1 "${work_dir}/blood_hg38_hic.txt" > $output
for file in ${work_dir}/split/chunk_*_with_count.txt; do
    echo "Processing ${file}"
    tail -n +2 ${file} >> $output
done

# eqtl to bed
awk 'NR>=2 {print $2"\t"($3-1)"\t"$3}' merged_with_count.txt > ./blood_eqtls.bed
awk 'NR>=2 {printf "%s\t%s\t%s\n", $2, int($3-1), int($3)}' merged_with_count.txt > ./blood_eqtls.bed
