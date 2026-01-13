#!/bin/bash

wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/GBM
#  --- 这个脚本的作用是找/cluster2/home/futing/Project/GBM/RNA/sample 的RNA数据 
# ----- 01 rename the EGA genes results
awk 'BEGIN{FS=OFS="\t"} {new=$3; sub(/\.bam/, ".genes.results", new); print $0, new}' EGA_RNAmeta.txt \
| cut -f1,2,3,4,6,9 > tmp && mv tmp EGA_RNAmeta.txt

IFS=$'\t'
while read -r newprefix oldname;do
	newname=${newprefix}.genes.results
	echo "mv $oldname -> $newname"
	mv $oldname $newname
done < <(cut -f2,6 ${wkdir}/sample/EGA_RNAmeta.txt)

# ------- 02 处理metafile
metadata_file="${wkdir}/srrmeta.tsv"
>$metadata_file
while read -r file; do
    echo "Processing $file..."
    # file_list+=("$file")
    srr=$(basename "$file" .genes.results)
    # # 提取 rsem_out 上一级目录名
    group=$(echo "$file" | awk -F'/' '{print $(NF-3)}')
    echo -e "$srr\t$group\t$file" >> "$metadata_file"
done < <(find -L ${wkdir}/sample -name '*genes.results')

# 将第二列是GBM行的替换为第一列，将 cell name 重命名，添加新的一列
awk 'BEGIN{FS=OFS="\t"}{
    if($2=="GBM") $2=$1
    count[$2]++
    unique_name = (count[$2] > 1) ? $2 "_" count[$2] : $2
    print unique_name, $0
}' $metadata_file > tmp && mv tmp $metadata_file

# ----- 03 合并并替换列名
file_list=()
while read -r file; do 
    file_list+=("$file")
done < <(cut -f4 $metadata_file)

sh /cluster2/home/futing/Project/GBM/RNA/merge/count.sh GBM "${file_list[@]}"

# 将srr 替换为 cell_name_rep
for type in count tpm;do
awk 'BEGIN{FS=OFS="\t"} 
     NR==FNR{map[$2]=$1; next}
     {
         if(FNR==1){
             for(i=1;i<=NF;i++) 
                 if($i in map) $i=map[$i]
         }
         print
     }' ${wkdir}/srrmeta.tsv \
	 ${wkdir}/GBM-${type}-matrix.txt > tmp && mv tmp ${wkdir}/GBM-${type}-matrix.txt
done

# --- 去掉 .之后的内容，如果重复则相加
split_script=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/splitID.py
GSCfile=${wkdir}/sample/GSE229965_all_GSCs_RNAcounts.txt
python ${split_script} $GSCfile

for type in count tpm;do
python ${split_script} ${wkdir}/GBM-${type}-matrix.txt
done

join -t $'\t' -1 1 -2 1 <(tr ',' '\t' < GBM_gene_count.csv |sort -k1) \
<(sort -k1 /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/GBM/sample/GSE229965_all_GSCs_RNAcounts_ID.txt) > tmp
grep 'GeneID' tmp > GBM_all_gene_count.tsv
grep -v 'GeneID' tmp >> GBM_all_gene_count.tsv

mv ${wkdir}/GBM-count-matrix_ID.txt ${wkdir}/GBM_gene_count.tsv
mv ${wkdir}/GBM-tpm-matrix_ID.txt ${wkdir}/GBM_TPM.tsv