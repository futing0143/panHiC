#getCountPasteLoop_list.sh

for i in {00..10}; do
        value=`cat fileList.${i}.txt`
        indivs="$value"

        echo "$indivs" > peak_by_sample_matrix.${i}.txt
        echo -n "paste" > paste.Job.${i}.sh     
        file=/path/to/lists${i}
        for FILE in `cat \$file`
        do

                string=$FILE
                prefix="/path/to/"
                suffix=".count.unionPeaks.bed_matrix"

                prefix_removed_string=${string/#$prefix}
                suffix_removed_String=${prefix_removed_string/%$suffix}
                
        
                echo -n " <(cut -f 5 -d  "\" "\"  $FILE)" >> paste.Job.${i}.sh
        done
        echo -n " >> peak_by_sample_matrix.${i}.txt" >> paste.Job.${i}.sh
        bsub -e paste.Job.${i}.err.txt -o paste.Job.${i}.out.txt -M 70000 bash paste.Job.${i}.sh
done
