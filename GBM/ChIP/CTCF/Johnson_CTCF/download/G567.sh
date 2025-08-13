#!/bin/bash

cd /cluster/home/futing/Project/GBM/CTCF/GSE121601/download
rep1=/cluster/home/futing/Project/GBM/CTCF/GSE121601/download/GSM3439933_G567_ctcf_ip_rep1_WRT_G567_ctcf_input_rep1_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/CTCF/GSE121601/download/GSM3439934_G567_ctcf_ip_rep2_WRT_G567_ctcf_input_rep1_peaks.narrowPeak

# IDR

sort -k8,8nr ${rep1} > rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > rep2_sorted.narrowPeak


idr --samples rep1_sorted.narrowPeak rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --rank p.value \
        --output-file G567-idr.bed \
        --plot \
        --log-output-file g567_idr.log

bedtools intersect -a ${rep1} -b ${rep2} -f 0.5 -r -wo > G567.bed