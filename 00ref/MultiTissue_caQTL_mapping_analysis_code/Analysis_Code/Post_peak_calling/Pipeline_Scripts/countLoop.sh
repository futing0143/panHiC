#countLoop.sh

for FILE in /path/to/bamFiles/*.q10_filtered.bam; do
string=$FILE
prefix="/path/to/bamFiles/"
suffix=".q10_filtered.bam"

prefix_removed_string=${string/#$prefix}
    suffix_removed_String=${prefix_removed_string/%$suffix}
    
    bedFile=$PWD/$suffix_removed_String.count_file
    
    if [ -f "$bedFile" ]; then
    echo "$bedFile exists."
    else
      
      echo "bedtools intersect -abam $FILE -b genrich_allYuanSamples_3.8.22.sorted.txt -wo -bed | sed 's/\/1//g' | sed 's/\/2//g' | awk '{print \$4,\$16}' | sort | uniq | awk '{print \$2}' | sort | uniq -c | awk '{print \$2,\$1}' | sort -k1,1 -k2,2n | sed 's/ / /g' > $PWD/$suffix_removed_String.count_file" > $suffix_removed_String.count.sh
    
    bsub -e $suffix_removed_String.countErr.txt -o $suffix_removed_String.countOut.txt sh $suffix_removed_String.count.sh
    
    fi
done