#!/bin/bash
 

#  --- 这个脚本的作用是找GBM cell line, NPC, NHA, iPSC, pHGG 的RNA数据 
# 处理meta 信息

file_list=()
metadata_file="/cluster/home/futing/Project/GBM/RNA/merge/meta/srr_idv2.tsv"

while read -r file; do
    echo "Processing $file..."
    file_list+=("$file")
    srr=$(basename "$file" .genes.results)
    # # 提取 rsem_out 上一级目录名
    group=$(echo "$file" | awk -F'/' '{print $(NF-3)}')
    echo -e "$srr\t$group\t$file" >> "$metadata_file"
done < <(find -L /cluster/home/futing/Project/GBM/RNA/sample -name '*genes.results')

sh /cluster/home/futing/Project/GBM/RNA/count.sh RNAall "${file_list[@]}"


# rerun resem?
# rsem-calculate-expression --paired-end -no-bam-output --alignments -p 20 \
# 	${FASTQ_DIR}/aligned/${i}Aligned.toTranscriptome.out.bam \
# 	/cluster/home/futing/ref_genome/hg38_gencode/RSEM/RSEM \
# 	${FASTQ_DIR}/rsem_out/${i}
genebed=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.bed
awk -F'\t' 'BEGIN{OFS="\t"} {split($4, a, "."); $4=a[1]; print $1,$2,$3,$4}' $genebed > ENSG.bed
