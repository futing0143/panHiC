##CGC网站下载后保留1、4列，对第4列进行分列
awk 'BEGIN{FS=OFS="\t"; NR>1} {if ($4 ~ /[:-]/) {split($4, a, /[:-]/); print "chr" a[1], a[2], a[3], $1, $15, $20}}' Census_all.txt > Census_G.txt
##去掉没有坐标的基因，没有注释的基因用otherCGC替代
awk 'BEGIN{FS=OFS="\t"} ($2 != "") {if ($5 == "") $5 = "otherCGC"; print $0}' Census_G.txt > filtered_Census_G.bed

#planA: 从ABC提供的Tss结果中提取
CGC_file="/cluster/home/tmp/GBM/HiC/08TAD/Census_G.txt"
ref_data="/cluster/home/jialu/biosoft/ABC-Enhancer-Gene-Prediction/reference/hg38/CollapsedGeneBounds.hg38.TSS500bp.bed"
output_file="/cluster/home/tmp/GBM/HiC/08TAD/CGCforABC.hg38.tss.bed"

awk '{if ($4 != "") print $4}' $ref_data > gene_bounds_column4.txt
awk '{if ($7 != "") print $7}' $ref_data > gene_bounds_column7.txt

# 清空或创建输出文件
> $output_file

# 遍历Census_G.txt文件的每一行
while read -r line; do
    # 提取Census_G.txt的第4列的基因名
    gene_name=$(echo "$line" | awk '{print $4}')
    # 提取Census_G.txt的第6列的所有基因名
    gene_names_list=$(echo "$line" | awk '{print $6}')

    # 检查基因名是否在基因边界文件的第4列中
    if grep -Fxq "$gene_name" gene_bounds_column4.txt; then
        awk -v gene_name="$gene_name" '$4 == gene_name {print $1, $2, $3, $4, $7}' $ref_data >> $output_file
        continue
    fi

    # 基因名不在第4列中，检查第6列的基因名是否在基因边界文件的第4列中
    IFS=',' read -ra gene_names_array <<< "$gene_names_list"
    found=0
    for name in "${gene_names_array[@]}"; do
        if grep -Fxq "$name" gene_bounds_column4.txt; then
            if [ $found -eq 0 ]; then
                awk -v name="$name" '$4 == name {print $1, $2, $3, $4, $7}' $ref_data >> $output_file
                found=1
            fi
            break
        fi
    done
    [ $found -eq 1 ] && continue

    # 如果前两个条件都不满足，检查ENSG号是否在基因边界文件的第7列中
    ensg=$(echo "$line" | grep -o 'ENSG[0-9]\{11\}' | head -1)
    if [ ! -z "$ensg" ] && grep -Fxq "$ensg" gene_bounds_column7.txt; then
        awk -v ensg="$ensg" '$7 == ensg {print $1, $2, $3, $4, $7}' $ref_data >> $output_file
    fi
done < $CGC_file

# 清理临时文件
rm gene_bounds_column4.txt gene_bounds_column7.txt



##planB: 从genecode提供的Tss结果中提取
CGC_file="/cluster/home/tmp/GBM/HiC/08TAD/Census_G.txt"
ref_data="/cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.tss.bed"
output_file="/cluster/home/tmp/GBM/HiC/08TAD/CGCforgenecode.hg38.tss.bed"

# 创建一个包含基因边界文件第7列的列表
awk '{if ($7 != "") print $7}' $ref_data > ref_gene.txt

# 创建一个包含基因边界文件第4列的前15个字符的列表
awk '{if ($4 != "") print substr($4, 1, 15)}' $ref_data > ref_ensg.txt

# 清空或创建输出文件
> $output_file

# 遍历Census_G.txt文件的每一行
while read -r line; do
    # 提取Census_G.txt的第4列的基因名
    gene_name=$(echo "$line" | awk '{print $4}')
    # 提取Census_G.txt的第6列的所有基因名
    gene_names_list=$(echo "$line" | awk -F'\t' '{print $6}')

    # 检查基因名是否在基因边界文件的第7列中
    if grep -Fxq "$gene_name" ref_gene.txt; then
        awk -v gene_name="$gene_name" '$7 == gene_name {print $1, $2, $3, $7, $4}' $ref_data >> $output_file
        continue
    fi

    # # 基因名不在第7列中，检查第6列的基因名是否在基因边界文件的第7列中
    IFS=',' read -ra gene_names_array <<< "$gene_names_list"
    found=0
    for name in "${gene_names_array[@]}"; do
        if grep -Fxq "$name" ref_gene.txt; then
            echo $name
            if [ $found -eq 0 ]; then
                awk -v name="$name" '$7 == name {print $1, $2, $3, $7, $4, $1}' $ref_data >> $output_file
                found=1
            fi
            break
        fi
    done
    [ $found -eq 1 ] && continue

    # # 如果前两个条件都不满足，检查ENSG号是否在基因边界文件的第7列中
    ensg=$(echo "$line" | grep -o 'ENSG[0-9]\{11\}' | head -1)  # 提取 ENSG 和其后 11 位
    if [ ! -z "$ensg" ]; then
        # 去掉 ENSG 版本号（.后的部分）以便只用 ENSG 及其 11 位进行匹配
        ensg_base=$(echo "$ensg" | cut -d'.' -f1)
        if grep -Fxq "$ensg_base" ref_ensg.txt; then
            awk -v ensg="$ensg_base" '$4 ~ ensg {print $1, $2, $3, $7, $4}' $ref_data >> $output_file
        fi
    fi

done < $CGC_file

# 清理临时文件
rm ref_gene.txt ref_ensg.txt

sed 's/\(.*\)\..*/\1/' /cluster/home/tmp/GBM/HiC/08TAD/CGCforgenecode.hg38.tss.bed \
    | awk 'BEGIN {OFS="\t"} {$1=$1; print}' > temp.bed \
    && mv temp.bed /cluster/home/tmp/GBM/HiC/08TAD/CGCforgenecode.hg38.tss.bed



