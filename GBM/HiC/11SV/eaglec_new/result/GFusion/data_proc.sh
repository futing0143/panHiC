##01 translocation的两条链会被记录两次，在原文件上进行去重
# find . -name "*gene-fusions.txt" | while read file; do
# 	sort "$file" | uniq > temp && mv temp "$file"
# 	wc -l $file
# done

##02 合并到一个表
awk 'BEGIN {FS="\t"; OFS="\t"} 
    {gsub(/.gene-fusions.txt/, "", FILENAME); 
    split($5, arr, ","); 
    for (i in arr) print FILENAME, $1, $2, $3, $4, arr[i];}' *.gene-fusions.txt > gene_fusions_combined.txt

##3 对相同的基因融合去重，基因邻近的位置被记录两次
awk 'BEGIN{FS=OFS="\t"} !seen[$1,$6]++' gene_fusions_combined.txt > gene_fusions_combined_uni.txt

#统计GF出现的次数
awk 'BEGIN{FS=OFS="\t"} {count[$6]++} END{for (i in count) print i, count[i]}' gene_fusions_combined_uni.txt | sort -k2,2nr > gene_fusions_count.txt
