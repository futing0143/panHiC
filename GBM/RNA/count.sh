#!/bin/bash

#----------------------------------注释-------------------------------------#
# 这个脚本的作用是获取所有的文件路径及文件名，然后把文件名写入到 ${name}-fpkm-matrix.txt 中
# 现在改为接受一系列文件路径作为参数输入。
# 用法示例：
# ./script_name.sh ./rsem_out/*genes.results
# 或
# ./script_name.sh name file1.genes.results file2.genes.results ...
#--------------------------------------------------------------------------#

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <name> <list of files>"
    echo "Please provide a name and one or more genes.results files as input."
    exit 1
fi

list_csv=""
list_name="gene"
name=$1
shift

# 遍历所有传递的文件参数
for i in "$@"
do
    # 把所有的 genes.results 文件路径加入到 list_csv 中
    list_csv="${list_csv} ${i}"
    # 提取文件名（不带扩展名）并加入到 list_name 中
    i_name2=$(basename "$i" .genes.results)
    list_name="${list_name}\t${i_name2}"
done


# 写入文件名列表到输出文件，使用制表符分隔
printf "$list_name\n" > ./${name}-fpkm-matrix.txt
printf "$list_name\n" > ./${name}-tpm-matrix.txt
printf "$list_name\n" > ./${name}-count-matrix.txt

# 调用 Python 脚本，处理 FPKM、TPM 和 count 数据
python /cluster/home/futing/pipeline/RNA/feature-count-extract.py 6 ${list_csv} >> ./${name}-fpkm-matrix.txt
python /cluster/home/futing/pipeline/RNA/feature-count-extract.py 5 ${list_csv} >> ./${name}-tpm-matrix.txt
python /cluster/home/futing/pipeline/RNA/feature-count-extract.py 4 ${list_csv} >> ./${name}-count-matrix.txt
