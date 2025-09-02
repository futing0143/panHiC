# #01 将数据格式统一
# sed 's/"//g; s/  */\t/g' /cluster/home/futing/Project/GBM/RNA/GSC28_TPM.txt > /cluster/home/futing/Project/GBM/RNA/GSC28_TPM_new.txt
# #读取done.list的每一行，假设文件路径在第一列，类别信息在第二列
# while IFS=$'\t' read -r file_path category; do
#   # 检查文件是否存在
#   if [ -f "$file_path" ]; then
#     # 使用sed命令查看文件的前两行，并显示格式化输出
#     echo "文件: $file_path"
#     sed -n '1,2l' "$file_path"  # 使用sed的l命令查看前两行
#     echo "----------------------"
#   else
#     echo "文件不存在: $file_path"
#   fi
# done < tpm.list


# ##02 查看首列是否一致
# first_file=$(awk '{print $1}' count.list | head -n 1)
# first_column=$(awk '{print $1}' $first_file)

# # 遍历done.list中的每个文件，比较第一列
# while read -r line; do
#     # 获取文件路径
#     file=$(echo $line | awk '{print $1}')
    
#     # 提取当前文件的第一列
#     current_column=$(awk '{print $1}' $file)
    
#     # 比较第一列
#     if [ "$first_column" == "$current_column" ]; then
#         echo "$file: same"
#     else
#         echo "$file: diff"
#     fi
# done < count.list  ###前7个文件一样，pHGG/NPC/EGA一样，GSC28单独

# # 03 开始合并
cd /cluster/home/tmp/GBM/RNA/subtype_TPM/count_merge
#files=$(awk 'NR<=7 {print $1}' ../count.list)

# paste $files > merged_first7.txt
# awk 'BEGIN {FS=OFS="\t"} NR==1 {print $0} NR>1 {print substr($1, 1, 15), substr($0, length($1)+2)}' merged_first7.txt > temp_file && mv temp_file merged_first7.txt

# files=$(awk 'NR>=8 && NR<=10 {print $1}' ../count.list)
# paste $files > merged_second3.txt
# awk 'BEGIN {FS=OFS="\t"} NR==1 {print $0} NR>1 {print substr($1, 1, 15), substr($0, length($1)+2)}' merged_second3.txt > temp_file && mv temp_file merged_second3.txt

files=$(awk 'NR>=12 && NR<=13 {print $1}' ../count.list)
paste $files > merged_last2.txt
awk 'BEGIN {FS=OFS="\t"} NR==1 {print $0} NR>1 {print substr($1, 1, 15), substr($0, length($1)+2)}' merged_last2.txt > temp_file && mv temp_file merged_last2.txt

# ##04 最终合并
# merged_output1.txt merged_output2.txt /cluster/home/tmp/GBM/RNA/GSC28_TPM_new.txt的合并在GSEA.R里

