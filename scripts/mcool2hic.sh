#!/bin/bash

# Set the path to the input .mcool file
input_mcool=$1
resolution=$2


dir=$(dirname "$(dirname "${input_mcool}")")
output_hic=${dir}/aligned/inter_30.hic
cd ${dir}

chrom_sizes=/cluster2/home/futing/ref_genome/hg38.genome
juicer_tools_jar=/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar

# if input_mcool ends with .mcool
if [[ $input_mcool == *.mcool ]]; then
    echo "input_mcool ends with .mcool"
    resolutions=$(h5ls -r $input_mcool | grep -Eo 'resolutions/[0-9]+' | cut -d '/' -f 2 | sort -n | uniq)
    echo $resolutions
    highest_res=$(echo $resolutions | tr ' ' '\n' | head -n 1)
    echo "highest resolution: $highest_res"

    #output_bedpe=$(echo $input_mcool | sed "s/.mcool/.${highest_res}.bedpe/")
    output_bedpe=$(basename $input_mcool | sed "s/.mcool/.${highest_res}.bedpe/")
    echo -e "cooler dump --join -r $highest_res $input_mcool::/resolutions/$highest_res"
    cooler dump --join $input_mcool::/resolutions/$highest_res | \
	awk -F "\t" '{print 0, $1, $2, 0, 0, $4, $5, 1, $7}' | \      #juicer的short format 
	sort -k2,2d -k6,6d --parallel=20 > $output_bedpe              # sort chr1 chr2

    # Convert the short format with score file to .hic using juicer pre  --threads 30
    java -Xmx200G -jar $juicer_tools_jar pre -j 20 $output_bedpe $output_hic $chrom_sizes

elif [[ $input_mcool == *.cool ]]; then
    echo "input_mcool does not end with .mcool"

    #output_bedpe=$(echo $input_mcool | sed "s/.cool/.${resolution}.bedpe/")
    output_bedpe=$(basename $input_mcool | sed "s/.cool/.${resolution}.bedpe/")
    echo -e "cooler dump --join -r ${resolution} $input_mcool"
    cooler dump --join $input_mcool |\
	awk -F "\t" '{print 0, $1, $2, 0, 0, $4, $5, 1, $7}' | \
	sort -k2,2d -k6,6d --parallel=20 > $output_bedpe

    # Convert the short format with score file to .hic using juicer pre
    java -Xmx400G -jar $juicer_tools_jar pre --threads 30 -j 20 $output_bedpe $output_hic $chrom_sizes
fi
