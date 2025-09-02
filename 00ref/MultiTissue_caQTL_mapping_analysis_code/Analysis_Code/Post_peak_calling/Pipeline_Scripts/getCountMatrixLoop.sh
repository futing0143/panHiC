#getCountMatrixLoop.sh

for FILE in /path/to/*.count_file; do
string=$FILE
prefix="/path/to/"
suffix=".count_file"

prefix_removed_string=${string/#$prefix}
    suffix_removed_String=${prefix_removed_string/%$suffix}
    
    matrixFile=/path/to/${suffix_removed_String}.count.unionPeaks.bed_matrix
    
    if [ -f "$matrixFile" ]; then
    echo "$matrixFile exists."
    else
      
      echo "join -e0 -a 1 -a 2 -j 1 <(awk "\"{{print \$4}}"\" genrich_allYuanSamples_3.8.22.forIntersect.final.txt) -o auto <(cat ${suffix_removed_String}.sorted.txt) | awk "\"{{print \$2}}"\" > ${suffix_removed_String}.count.unionPeaks.bed_matrix" > ${suffix_removed_String}.countMatrixJob.sh
    bsub -e ${suffix_removed_String}.countMat.err.txt -o ${suffix_removed_String}.countMat.out.txt bash ${suffix_removed_String}.countMatrixJob.sh  
    fi
done