#!/bin/bash

# for seed in 1 2 3 4 5; do
#   awk -v seed=$seed 'BEGIN{srand(seed)} {print rand() "\t" $0}' sample_ATAC.bed \
#     | sort -k1,1n \
#     | head -n 50000 \
#     | cut -f2- \
#     > sample_ATAC.ds50000.rep${seed}.bed
# done


N=50000
SEED=1
OUTDIR=/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/downsampled_ATAC
mkdir -p $OUTDIR

IFS=$'\t'
while read cancer f; do

  awk -v seed=$SEED 'BEGIN{srand(seed)} {print rand() "\t" $0}' $f \
    | sort -k1,1n \
    | head -n $N \
    | cut -f2- \
    > $OUTDIR/${cancer}.ds${N}.bed
done < "/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/ATAC_bedlist_dsample.txt"


awk 'BEGIN{OFS=FS="\t"}{
print $1,"/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/downsampled_ATAC/"$1".ds50000.bed"
}' /cluster2/home/futing/Project/panCancer/Analysis/anno_loops/ATAC_bedlist_dsample.txt \
> /cluster2/home/futing/Project/panCancer/Analysis/anno_loops/ATAC_bedlist_dsample_ds50000.txt
