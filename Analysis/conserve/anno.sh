#!/bin/bash


wkdir=/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/pathway
mkdir -p $wkdir && cd $wkdir

annodir=/cluster2/home/futing/Project/panCancer/GBM/HiC/09insulation/con_Boun/annotation/
# bed=/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/50k800k.bed
bed=/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/412/Ctrl_50k800k.bed
end="ctrl_50k800k"

# CGC TSS
bedtools intersect -a ${annodir}/Census_tss.bed \
	-b <(tail -n +2 ${bed} | cut -f1-3) \
	-wao > ./CGC_${end}_all.bed
awk 'BEGIN{FS=OFS="\t"}$10 ==1' ./CGC_${end}_all.bed > ./CGC_${end}.bed #22/742
cut -f4 ./CGC_${end}.bed > CGC_${end}.txt

# CGC TSS upstream & downstream 500bp
bedtools intersect -a ${annodir}/CGC_tss_500ud.bed -b <(tail -n +2 ${bed} | cut -f1-3) \
	-wao \
	> ./CGCud_${end}_all.bed
awk 'BEGIN{FS=OFS="\t"}$9 != 0' ./CGCud_${end}_all.bed > ./CGCud_${end}.bed #409/20784
cut -f5 ./CGCud_${end}.bed > CGCud_${end}.txt

# PCG TSS
PCG=/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss/pcg.bed
bedtools intersect -a <(cut -f1-3,7 $PCG) \
	-b <(tail -n +2 ${bed} | cut -f1-3) -wao | \
	awk 'BEGIN{FS=OFS="\t"}$8 ==1' > PCG_${end}.bed
cut -f4 PCG_${end}.bed > PCG_${end}.txt




# ---- step 2 将 cancer ctrl 对比
# ctrl单独有
for type in CGC CGCud PCG;do
	mkdir -p ${wkdir}/${type}
	comm -23  <(sort ${type}_ctrl_50k800k.txt) <(sort ${type}_panCan_50k800k.txt) > ./${type}/${type}_ctrluniq.txt
	comm -13 <(sort ${type}_ctrl_50k800k.txt) <(sort ${type}_panCan_50k800k.txt) > ./${type}/${type}_panCanuniq.txt
	comm -12 <(sort ${type}_ctrl_50k800k.txt) <(sort ${type}_panCan_50k800k.txt) > ./${type}/${type}_comm.txt
done 


# ---- step3 cancer ctrl bin预处理
wkdir=/cluster2/home/futing/Project/panCancer/Analysis/conserve
for type in panCan Ctrl;do
	cut -f1-3 ${wkdir}/midata/412/strict/${type}_50k800k.bed \
		| awk 'BEGIN{FS=OFS="\t"}{print $1"_"$2"_"$3}' \
		> ${wkdir}/midata/412/strict/${type}_50k800kbin_id.bed
done
