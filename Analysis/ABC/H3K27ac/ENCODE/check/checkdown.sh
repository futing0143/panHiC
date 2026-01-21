#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/ENCODE
awk -F'\t' '{
  n=split($48,a,"/");
  $48=a[n];
  print $48 "\t" $44
}' /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/ENCODE/metadata_encode.tsv | tail -n +2 | sort -k1 -k2 > filesize.txt

find . \( -name '*.bigWig' -o -name '*.bed.gz' \) -exec ls -l {} \; | awk '{
  n=split($9,a,"/");
  $9=a[n];
  print $9, $5}'  | sed 's/ /\t/g' | sort -k1 -k2 > actual_size.txt

join -1 1 -2 1 -t $'\t' filesize.txt actual_size.txt | awk -F'\t' '{
  if ($2 != $3) {
	print $1
  }
}' > checkdown.txt

grep -w -v -F -f <(cut -f1 actual_size.txt) <(cut -f1 filesize.txt) >> checkdown.txt

# grep -F -f checkdown.txt /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/ENCODE/files_bigwig.txt > H3K27ac_1230.txt