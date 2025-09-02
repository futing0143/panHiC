#!/bin/bash

# per software

input_file="/cluster/home/futing/Project/GBM/HiC/10loop/consensus/namelist.txt"
output_idr=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/loopsize
# peakachu
echo -e "chr\tlength\tname" > ${output_idr}/peakachu.txt
while read name; do
    awk -v name="$name" '
    BEGIN {FS=OFS="\t"}
    NR >2 && $4 != "NA" {
        print $1, $3-$2, name
    }
    ' "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed" >> ${output_idr}/peakachu.txt
done < "$input_file"

# mustache
echo -e "chr\tlength\tname" > ${output_idr}/mustache.txt
while read name; do
    awk -v name="$name" '
    BEGIN {FS=OFS="\t"}
    $5 != "NA" && NR > 1 {
        print $1, $3-$2, name
    }
    ' "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed" >> ${output_idr}/mustache.txt
done < "$input_file"

#cooldots
echo -e "chr\tlength\tname" > ${output_idr}/cooldots.txt
while read name; do
    awk -v name="$name" '
    BEGIN {FS=OFS="\t"}
    $6 != "NA" && NR > 1 {
        print $1, $3-$2, name
    }
    ' "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed" >> ${output_idr}/cooldots.txt
done < "$input_file"

#hiccups
echo -e "chr\tlength\tname" > ${output_idr}/hiccups.txt
while read name; do
    awk -v name="$name" '
    BEGIN {FS=OFS="\t"}
    $7 != "NA" && NR > 1 {
        print $1, $3-$2, name
    }
    ' "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed" >> ${output_idr}/hiccups.txt
done < "$input_file"

#fithic
echo -e "chr\tlength\tname" > ${output_idr}/fithic.txt
while read name; do
    awk -v name="$name" '
    BEGIN {FS=OFS="\t"}
    $8 != "NA" && NR > 1 {
        print $1, $3-$2, name
    }
    ' "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed" >> ${output_idr}/fithic.txt
done < "$input_file"


# per sample
echo -e "chr\tlength\tname" > ${output_idr}/sample.txt
while read name; do
    awk -v name="$name" '
    BEGIN {FS=OFS="\t"}
    $10 != "2" && NR > 1 {
        print $1, $3-$2, name
    }
    ' "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed" >> ${output_idr}/sample.txt
done < "$input_file"