while read -r i
do
  # 直接使用 read 读取两个文件名
  bed=$(echo "$i" | awk '{print $1}')
  merge=$(echo "$i" | awk '{print $2}')
  
  # 获取文件所在的目录路径
  dir=$(dirname "$bed")
  echo -e "Processing $bed and $merge in $dir... \n"
  awk 'BEGIN {OFS="\t"}
                 (FNR==NR) {
                     a[$NF] = $2;
                     next;
                 }
                 ($NF in a) {
                     $7 = a[$NF];
                     print;
                 }' "$bed" "$merge" > "$dir/tmp.txt"
done < file2
