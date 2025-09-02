#!/bin/bash

# Set the path to the input .mcool file
input_mcool=$1
resolution=$2

output_hic=${input_mcool%%.*}.hic
chrom_sizes=/cluster/home/futing/ref_genome/hg38.chrom.sizes
juicer_tools_jar=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar

# if input_mcool ends with .mcool
if [[ $input_mcool == *.mcool ]]; then
    echo "input_mcool ends with .mcool"
    # Get the resolutions stored in the .mcool file
    resolutions=$(h5ls -r $input_mcool | grep -Eo 'resolutions/[0-9]+' | cut -d '/' -f 2 | sort -n | uniq)
    echo $resolutions
    highest_res=$(echo $resolutions | tr ' ' '\n' | head -n 1)
    echo "highest resolution: $highest_res"

    # Use Cooler to write the .mcool matrix as interactions in bedpe format
    #output_bedpe=$(echo $input_mcool | sed "s/.mcool/.${highest_res}.bedpe/")
    output_bedpe=$(basename $input_mcool | sed "s/.mcool/.${highest_res}.bedpe/")
    echo -e "cooler dump --join -r $highest_res $input_mcool::/resolutions/$highest_res"
    cooler dump --join $input_mcool::/resolutions/$highest_res > $output_bedpe

    # Convert the ginteractions file to short format with score using awk
    awk -F "\t" '{print 0, $1, $2, 0, 0, $4, $5, 1, $7}' ${output_bedpe} > ${output_bedpe}.short

    # Sort the short format with score file
    sort -k2,2d -k6,6d --parallel=20 ${output_bedpe}.short > ${output_bedpe}.short.sorted

    # Convert the short format with score file to .hic using juicer pre  --threads 30
    java -Xmx200G -jar $juicer_tools_jar pre -j 20 ${output_bedpe}.short.sorted $output_hic $chrom_sizes

elif [[ $input_mcool == *.cool ]]; then
    echo "input_mcool does not end with .mcool"

    # Use Cooler to write the .mcool matrix as interactions in bedpe format
    #output_bedpe=$(echo $input_mcool | sed "s/.cool/.${resolution}.bedpe/")
    output_bedpe=$(basename $input_mcool | sed "s/.cool/.${resolution}.bedpe/")
    echo -e "cooler dump --join -r ${resolution} $input_mcool"
    cooler dump --join $input_mcool > $output_bedpe

    # Convert the ginteractions file to short format with score using awk
    awk -F "\t" '{print 0, $1, $2, 0, 0, $4, $5, 1, $7}' ${output_bedpe} > ${output_bedpe}.short

    # Sort the short format with score file
    sort -k2,2d -k6,6d --parallel=20 ${output_bedpe}.short > ${output_bedpe}.short.sorted

    # Convert the short format with score file to .hic using juicer pre
    java -Xmx400G -jar $juicer_tools_jar pre --threads 30 -j 20 ${output_bedpe}.short.sorted $output_hic $chrom_sizes
fi
