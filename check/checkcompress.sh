#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/check

grep 'Processing ' sam2bam-11659.log \
   | sed 's/Processing //g' \
   | sed 's/\.\.\.//g' \
   | awk 'BEGIN{OFS="\t";FS="/"}{print $1,$2,$3}' > sam2bam_done0829.txt

# grep -w -v -F -f sam2bam_done0827.txt ./hic/hicdone0827.txt > sam2bam_0827.txt

grep -w -v -F -f sam2bam_done0829.txt sam2bam_0827.txt > sam2bam_0829.txt

grep 'Processing ' gzip-11667.log \
   | sed 's/Processing //g' \
   | sed 's/\.\.\.//g' \
   | awk 'BEGIN{OFS="\t";FS="/"}{print $1,$2,$3}' > gzip_done0829.txt

grep -w -v -F -f gzip_done0829.txt gzip_0827.txt > gzip_0829.txt