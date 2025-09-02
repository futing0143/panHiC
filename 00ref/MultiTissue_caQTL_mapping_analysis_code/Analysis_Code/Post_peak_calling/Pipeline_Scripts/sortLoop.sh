#sortLoop.sh

for FILE in /path/to/*.count_file; do
string=$FILE
prefix="/path/too/"
suffix=".count_file"

prefix_removed_string=${string/#$prefix}
    suffix_removed_String=${prefix_removed_string/%$suffix}
    
    sortFile=/path/to/$suffix_removed_String.sorted.txt
    
    if [ -f "$sortFile" ]; then
    echo "$sortFile exists."
    
    else
      echo "sort -k1,1 $FILE > ${suffix_removed_String}.sorted.txt" > ${suffix_removed_String}.sortJob.sh
    
    bsub -e sortJob.${suffix_removed_String}.err.txt -o sortJob.${suffix_removed_String}.out.txt sh ${suffix_removed_String}.sortJob.sh
    fi      
done