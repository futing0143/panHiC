#!/bin/bash


awk -F'\t' '{
  n=split($48,a,"/");
  $48=a[n];
  print $48 "\t" $44
}' /cluster2/home/futing/public_data/ENCODE/ATAC/ENCODE_ATAC.tsv | tail -n +2 | sort -k1 -k2 > filesize.txt

ls -l | awk '{print $9, $5}' | grep 'ENCFF' | sed 's/ /\t/g' | sort -k1 -k2 > actual_size.txt

join -1 1 -2 1 -t $'\t' filesize.txt actual_size.txt | awk -F'\t' '{
  if ($2 != $3) {
    print $0
  }
}' > checkdown.txt

grep -w -v -F -f <(cut -f1 actual_size.txt) <(cut -f1 filesize.txt) >> checkdown.txt

grep -F -f checkdown.txt /cluster2/home/futing/public_data/ENCODE/ATAC/ATAC.txt > ATAC_1230.txt


cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/ENCODE
IFS=$'\t'
while read -r file type cell;do
    if [ ! -d ${cell} ];then
    mkdir -p ${cell}
    fi
    if [ $type == "bigWig" ];then
        echo "mv ${file}.bigWig ${cell}/"
        mv ${file}.bigWig ${cell}/
    elif [ $type == "bed" ];then
        echo "mv ${file}.bed.gz ${cell}/"
        mv ${file}.bed.gz ${cell}/
    fi

done < <(tail -n +2 /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/ENCODE/ENCODE_ATAC.tsv | cut -f1,3,11)