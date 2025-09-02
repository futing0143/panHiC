#01 提取neoloop有效结果
#/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/merged.bedpe 来自/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/02anno.sh

# #03 用chip注释
# while IFS=$' ' read -r file chip; do
#   matched_lines=$(awk -v pattern="$file" 'NF > 0 && $NF == pattern' /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/merged.bedpe)
#   if [ -n "$matched_lines" ]; then
#     echo "$matched_lines" | pairToBed -type xor -a - -b "$chip" > "${file}_paired.bedpe"
#   fi
# done < ../filename_chip

# #04 根据找到对应的assem
# output_file="assem.txt"
# > "$output_file"

# ##遍历当前目录下所有以 _paired.bedpe 结尾的文件
# for file in *_paired.bedpe; do
#     # 使用 sed 命令从文件名中移除 _paired.bedpe 部分
#     filename=$(basename "$file" | sed 's/_paired\.bedpe//')

#     # 逐行读取文件
#     while IFS= read -r line; do
#         echo -n "$filename"  # 将修改后的文件名写入第一列
#         echo "$line" | awk -F'\t' '{if (NF > 6) print $7}' | awk -F',' '{print $1}' | while read -r col; do
#             echo -n " $col"  # 将 awk 命令的输出追加到第二列
#         done
#         echo ""  # 添加一个换行符，以便每个文件的输出在新的一行
#     done < "$file" >> "$output_file"
# done

# # #删除有重复的assem并将空格改为~
# sort "assem.txt" | uniq > temp.txt && mv temp.txt assem.txt


#05 将具体的位置对应上
input_file="assem.txt"
output_file="output.txt"

# 如果输出文件已存在，则清空
> "$output_file"

while IFS='~' read -r file assem; do
    # 构造 ${file}.assemblies.txt 文件的路径
    assemblies_file="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/${file}/${file}.assemblies.txt"
    loop_file="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/${file}/${file}.neo-loops.txt"

    # 检查 ${file}.assemblies.txt 文件是否存在
    if [[ -f "$assemblies_file" ]]; then
        # 在 ${file}.assemblies.txt 文件中查找对应的 assem 行
        assembly_info=$(awk -v assem="$assem" -F'\t' '$1 == assem {print $0}' "$assemblies_file")

        #如果找到了对应的行，提取第二列并追加到输出文件
        if [[ -n "$assembly_info" ]]; then
            assembly_column=$(echo "$assembly_info" | awk '{print $0}')
            echo -e "${file}~${assembly_column}~${loop_file}" >> "$output_file"
        else
            echo "Assembly '$assem' not found in '$assemblies_file'" >&2
        fi
    else
        echo "File '$assemblies_file' not found" >&2
    fi
done < "$input_file"

###添加mcool文件地址和chip地址，手动加抬头
awk -F'~' 'NR==FNR {a[$1] = $2"~"$3; next} {if ($1 in a) {print $0"~"a[$1]} else {print $0}}' OFS="~" /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/file_cooler_chipbw /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/H3k27ac_label/output.txt > assem_with_assemblies.txt
rm output.txt


