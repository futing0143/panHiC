search_str=("SRR13238385" "SRR13238389" "SRR13238387")
replace_str=("SRR13238358_input" "SRR13238360_input" "SRR13238379_input")

# 外层循环，逐个处理每组搜索字符串和替换字符串
for ((i=0; i<${#search_str[@]}; i++)); do
  current_search_str="${search_str[i]}"
  current_replace_str="${replace_str[i]}"
  
  find . -type f -name "*$current_search_str*" -print0 | while IFS= read -r -d '' file
  do
    # 获取文件名部分
    filename=$(basename "$file")
    
    # 替换字符串
    new_filename="${filename//$current_search_str/$current_replace_str}"
    
    # 重命名文件
    mv "$file" "$(dirname "$file")/$new_filename"
    
    # 打印重命名的文件名
    echo "Renamed: $filename -> $new_filename"
  done
done
