#getHeaders.sh

for i in {00..10}; do
        file=/path/to/lists${i}
        for FILE in `cat \$file`
        do

                string=$FILE
                prefix=“/path/to/“
                suffix=".count.unionPeaks.bed_matrix"

                prefix_removed_string=${string/#$prefix}
                suffix_removed_String=${prefix_removed_string/%$suffix}

                printf '%s\t%s' $suffix_removed_String >> fileList.${i}.txt

        done
done
