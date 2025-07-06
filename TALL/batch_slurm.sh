#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/TALL
# IFS=$','
# while read -r gse cell enzyme other;do
# 	echo -e "$gse $cell $enzyme and $other"
# 	sh /cluster2/home/futing/Project/panCancer/TALL/sbatch.sh $gse $cell $enzyme
	
# done < '/cluster2/home/futing/Project/panCancer/TALL/done.txt'


# tail -n +2 /cluster2/home/futing/Project/panCancer/TALL/TALL_anno.csv | cut -f1,4,9 -d ',' | sort | uniq > TALL_meta.txt

IFS=$'\t'
while read -r gse cell tools other;do
	echo -e "$gse $cell $tools and $other"
	sh /cluster2/home/futing/Project/panCancer/TALL/sbatch_post.sh $gse $cell $tools
	
done < '/cluster2/home/futing/Project/panCancer/TALL/check/check_Jun27.txt'
