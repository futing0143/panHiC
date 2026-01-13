#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac
ENCODEmeta=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/metadata_encode.tsv
H3K27acdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/ENCODE

tail -n +2 "$ENCODEmeta" | cut -f1,3,11 | \
awk -v dir="$H3K27acdir" 'BEGIN{FS=OFS="\t"}
{
    if ($2 == "bed") {
        print $1, $3, $3, dir"/"$3"/"$1".bed.gz"
    } else {
        print $1, $3, $3, dir"/"$3"/"$1".bigWig"
    }
}' > ENCODE_H3K27ac2.txt


# Move files to corresponding cell type folder    
IFS=$'\t'
while read -r file cell path;do
    mkdir ./ENCODE/${cell}
    mv ${file}.bed.gz ./ENCODE/${cell}
done < "ENCODE_H3K27ac.txt"

IFS=$'\t'
while read -r file cell clcell path;do
    if [ ! -d ${cell} ];then
        mkdir -p ${cell}
    fi
    mv ${file}.bigWig ./${cell}
done < <(grep 'bigWig' ENCODE_H3K27ac2.txt)

# rename the folder
cut -f2,3 ENCODE_H3K27ac2.txt | sort -u | while read -r cell clcell;do
    if [ -d "./${cell}" ] && [ ! $cell == $clcell ];then
        echo "mv ./${cell} ./${clcell}"
        mv "./${cell}" "./${clcell}"
    fi
done


meta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt
cp $meta H3K27ac.txt

