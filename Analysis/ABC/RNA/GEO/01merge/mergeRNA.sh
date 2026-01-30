#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/01merge
# GBM 部分
metadata_file="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/GBM/srrmeta.tsv"
awk 'BEGIN{FS=OFS="\t"}{print "GBM_"$1,$2,$3,$4}' $metadata_file > tmp && mv tmp $metadata_file


file_list=()
while read -r file; do 
    file_list+=("$file")
done < <(cut -f4 $metadata_file)

# 其他部分
metap2=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/00meta/runRNA/RNA_GSE_srrtest.txt
IFS=$'\t'
while read -r cancer gsm;do
    file=/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/${cancer}/rsem_out/${gsm}.genes.results
	file_list+=("$file")
done < <(cut -f3,6 $metap2 | sort -u)
bash /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/01merge/count.sh panCanp1 ${file_list[@]}


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