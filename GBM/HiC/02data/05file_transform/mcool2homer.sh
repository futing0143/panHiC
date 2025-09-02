#!/bin/bash
res=5000
input_cool=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/5000/G208_5000.cool
output_bedpe=$(basename $input_mcool | sed "s/.mcool/.${highest_res}.bedpe/")
name=$(basename $input_cool _5000.cool )


echo -e "cooler dump --join -r ${res} $input_cool"
cooler dump --join $input_cool > $output_bedpe

awk -F "\t" '{print 0, $1, $2, +, $4, $5, -}' ${output_bedpe} > ${output_bedpe}.homer
