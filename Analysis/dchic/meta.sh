#!/bin/bash


search_anno=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/cell_list/cell_list_annotated.txt
meta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
awk 'NR==FNR{key=$1"\t"$3; data[key]=$0; next}
{
  key=$1"\t"$2
  if(key in data)
     print data[key]"\t"$3
}' $search_anno $ctrlmeta > $panCanmeta

# --- discarded 有问题，ctrl_meta的信息不是全的
# 生成 ./meta/cell_list/cell_list.txt
metadir=/cluster2/home/futing/Project/panCancer/check/meta/part
cat <(cut -f1-3 ${metadir}/ctrl_merge.txt) \
    <(cut -f1-3 /cluster2/home/futing/Project/panCancer/GBM/GBM_ctrl_sim.txt | awk 'BEGIN{FS=OFS="\t"}{print "GBM",$0}' | grep -Ev 'DIPG007|SF9427|DIPGXIII') \
    <(awk '($2 == "GSE207951" && $3 ~ /^A/) || ($3 ~ /^Norm_patient/) || ($3 ~ /_Normal$/)' ${metadir}/cancer_meta.txt| cut -f1-3) | \
awk 'BEGIN{FS=OFS="\t"} {print $1,$2,$3,1}' | sort -k1 -k2 -k3 -u > ./meta/cell_list/cell_list_ctrl.txt

cat <(awk '($2 != "GSE207951" || $3 !~ /^A/) && ($3 !~ /^Norm_patient/) && ($3 !~ /_Normal$/)' ${metadir}/cancer_meta.txt | cut -f1-3) \
	<(cut -f1-3 ${metadir}/done_meta.txt) \
	<(cut -f1-2 /cluster2/home/futing/Project/panCancer/GBM/GBM_meta.txt | awk 'BEGIN{FS=OFS="\t"}{print "GBM",$0}') \
	<(cut -f1-3 /cluster2/home/futing/Project/panCancer/GBM/GBM_ctrl_sim.txt | awk 'BEGIN{FS=OFS="\t"}{print "GBM",$0}' | grep -E 'DIPG007|SF9427|DIPGXIII') |\
	awk 'BEGIN{FS=OFS="\t"} {print $1,$2,$3,0}' | sort -k1 -k2 -k3 -u > ./meta/cell_list/cell_list_unctrl.txt

cat ./meta/cell_list/cell_list_ctrl.txt ./meta/cell_list/cell_list_unctrl.txt | sort -u > ./meta/cell_list/cell_list_all.txt
rm ./meta/cell_list/cell_list_ctrl.txt ./meta/cell_list/cell_list_unctrl.txt
