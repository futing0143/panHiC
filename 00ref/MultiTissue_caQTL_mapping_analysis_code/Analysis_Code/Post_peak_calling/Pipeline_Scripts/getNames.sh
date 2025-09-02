#getNames.sh

  for FILE in /path/to/*.count.unionPeaks.bed_matrix; do
  string=$FILE
  prefix="/path/to/"
  suffix=".count.unionPeaks.bed_matrix"
  
  prefix_removed_string=${string/#$prefix}
      suffix_removed_String=${prefix_removed_string/%$suffix}
      
      echo $prefix_removed_string >> fileList.txt
      
done