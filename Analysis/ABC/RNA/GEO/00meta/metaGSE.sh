
# 处理获得 header 的 GSE 信息，GSE_metadata.txt GSE_metadata_all.txt
# 2025.12


# 01 header 拆开为 cancer cell
awk 'BEGIN{FS=",";OFS="\t"}
FNR==1 {
  match(FILENAME, /p[0-9]+/, m)
  for (i = 1; i <= NF; i++) {
    print $i "\t" m[0]
  }
}
' mergedp*_TPM.csv > cell_process.txt


# 02 header type process cell
awk 'BEGIN{FS=OFS="\t"}
{
  if ($2 == "ENSG_TPM") {
    print $0
  } else if ($2 == "ENTREZ_TPM"){
    print $1,$2, "featureCounts"
  } else {
    print $1,$2, "unknown"
  }
}' cell_process.txt > tmp && mv tmp cell_process.txt

# 03 GSE_metadata.txt 是我的手动一个个查的
head -n1 /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/UCEC/UCEC_TPM.tsv \
    | tr '\t' '\n' | grep -v 'GeneID' | awk 'BEGIN{FS=OFS="\t"}{print $0,"GSE128229"}' >> GSE_metadata.txt
# 对一下结果
awk -F'\t' 'BEGIN{OFS="\t"} {n=index($1,"_"); 
print $0, substr($1,n+1)}' cell_process.txt  GSE_metadata.txt

# 04 将 cell gse 信息与cell process type 信息合并
join -a 1 -a2 -1 1 -2 4 -t$'\t'  GSE_metadata.txt cell_process.txt > GSE_metadata_all.txt
# 将 GSC 填充
awk -F'\t' 'BEGIN{OFS="\t"} {if($3=="" || $3=="NA") {$3=$1; $4="ENSG_TPM"; $5="RSEM"} print}' \
    GSE_metadata_all.txt > tmp && mv tmp GSE_metadata_all.txt

rm GSE_metadata.txt cell_process.txt