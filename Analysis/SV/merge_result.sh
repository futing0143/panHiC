#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/SV
wkdir=/cluster2/home/futing/Project/panCancer
GENE_BED=/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.bed
OUTDIR=/cluster2/home/futing/Project/panCancer/Analysis/SV/summary
metadata=/cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0106.txt
mkdir -p ${OUTDIR}


donefile=/cluster2/home/futing/Project/panCancer/check/post/SV/SV_0108.txt
# grep -E 'SV' /cluster2/home/futing/Project/panCancer/check/post/all/hicdone1224.txt | cut -f1-3  > \
# /cluster2/home/futing/Project/panCancer/check/post/SV/SV_0108.txt

# grep -F -w -f ${donefile} ${metadata} | cut -f1-3,7 > tmp && mv tmp ${donefile}

# ============================ 合并所有SV结果
# > "${OUTDIR}/all_SV_calls_0108.txt"
# IFS=$'\t'
# while read -r cancer gse cell ncell;do

# 	file=${wkdir}/${cancer}/${gse}/${cell}/anno/SV/${cell}.SV_calls.reformat.txt
# 	# awk -v c=${cancer} -v g=${gse} -v ce=${cell} -v nc=${ncell} \
# 	# 'BEGIN{FS=OFS="\t"}NR>1{print c,g,ce,nc,$1,$2,$2+$11,$3,$4,$4+$11}' $file >> \
# 	# ${OUTDIR}/all_SV_calls_0108.txt
# done < ${donefile}

# echo -e "cancer\tcell\tsv_id\tsv_type\tchr1\tpos1\tstrand1\tchr2\tpos2\tstrand2" \
# > ${OUTDIR}/all_sv.tsv
# IFS=$'\t'
# while read cancer gse cell ncell; do
#   file=${wkdir}/${cancer}/${gse}/${cell}/anno/SV/${cell}.assemblies.txt
#   python parse_SV.py $cancer $ncell ${file} >> ${OUTDIR}/all_sv.tsv
# done < "$donefile"

# #统计 cancer * SV
# awk -F'\t' 'NR>1{print $1"\t"$4}' ${OUTDIR}/all_sv.tsv \
# | sort | uniq -c \
# | awk '{print $2"\t"$3"\t"$1}' \
# > ${OUTDIR}/cancer_sv_frequency.tsv



# =============================================================
# 提取neo-loop相关基因
> ${OUTDIR}/all_loop_anchors.bed
while read -r cancer gse cell ncell; do
	loop=${wkdir}/${cancer}/${gse}/${cell}/anno/SV/${cell}.neo-loops.txt
	if [ -s "$loop" ]; then
	awk -v c="$cancer" -v ce="$cell" '
	BEGIN{FS=OFS="\t"}
	{
	split($7,a,","); flag=a[3]
	print c,ce,$1,$2,$3,flag,"A"
	print c,ce,$4,$5,$6,flag,"B"
	}' "$loop"
	fi
done < ${donefile} > ${OUTDIR}/all_loop_anchors.bed
awk -F'\t' 'BEGIN{OFS="\t"}{
  print $3,$4,$5,$1,$2,$6,$7
 }' all_loop_anchors.bed \
 > all_loop_anchors.bedtools.bed && mv all_loop_anchors.bedtools.bed ${OUTDIR}/all_loop_anchors.bed

bedtools intersect \
  -a ${OUTDIR}/all_loop_anchors.bed \
  -b $GENE_BED \
  -wa -wb \
> ${OUTDIR}/loop_gene.raw

awk -F'\t' '
{
  print $4,$5,$6,$14,$16
}' OFS="\t" \
${OUTDIR}/loop_gene.raw \
> ${OUTDIR}/SVloop_genes.tsv

awk -F'\t' '$6==1{
  print $4,$5,$6,$14,$16
}' OFS="\t" \
${OUTDIR}/loop_gene.raw \
> ${OUTDIR}/Neoloop_genes.tsv

# =============================================================


grep 'KLRD1' ${OUTDIR}/loop_gene.raw \
| cut -f4,5,6 | sort -u > KLRD1_samples.txt