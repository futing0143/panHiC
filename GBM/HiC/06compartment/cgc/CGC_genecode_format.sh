#awk -F'\t' '{print $4"\t"$1}' CensusG.txt | sed '1d' | sed -E 's/([^[:space:]]+):([[:digit:]]+)-([[:digit:]]+)/\1\t\2\t\3/g' >new.bed
#sed 's/^/chr/g' new.bed |grep -v ":-" | sort -k1,1V -k2,2n >sort.bed
#awk -F'\t' '{print $1}' CensusG.txt | sed '1d' > G.txt

#for i in SKNSH WTC NHA NPC pGBM GSC
#do
#intersectBed -a /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/10k_KR/tsv/GBM2${i}_3col_S.bed -b G_tss.bed -wa -wb >IS${i}.bed
#awk '{print $8"\t"$4}' IS${i}.bed | sort |uniq > ${i}
#done

#intersectBed -a /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/10k_KR/tsv/GBMall_sub_compartments.bed -b G_tss.bed -wa -wb >ISgbm.bed
#awk 'BEGIN {FS = OFS = "\t"} {$4 = substr($4, 1, 5)} 1' ISgbm.bed |awk '{print $1"\t"$4"\t"$10}' |sort -k1,1V -k2,2n  > ISgbm2.bed
for i in GBMmerge NPC ipsc
do
#awk 'BEGIN {FS = OFS = "\t"} {$4 = substr($4, 1, 5)} 1' /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/10k_KR/${i}/sub_compartments/${i}all_sub_compartments.bed |awk '{print $1"\t"$2"\t"$3"\t"$4}' > ${i}.bed
#intersectBed -a G_tss.bed -b ${i}.bed -wb |awk '{print $4"\t"$8}' > ${i}_G.bed
#intersectBed -a mutated_G.bed -b ${i}.bed -wb |awk '{print $4"\t"$8}' > ${i}_G_1.bed
#intersectBed -a G_tss.bed -b /cluster/home/jialu/GBM/HiC/otherGBM/cooltool_new/${i}2_nona.bed -wb -loj |awk '{print $4"\t"$8}' > ${i}_G_CGC.bed
#intersectBed -a gencodev38_gene.tss.bed -b /cluster/home/jialu/GBM/HiC/otherGBM/cooltool_new/${i}2_nona.bed -wb -loj |awk '{print $4"\t"$9}' > ${i}_G_all.bed
intersectBed -a gencodev38_gene.tss.bed -b /cluster/home/jialu/GBM/HiC/otherGBM/cooltool_new/${i}_nona.bed -wb -loj |awk '{print $4"\t"$9}' > ${i}_G_all.bed
done

#paste GBMmerge_G_all.bed GSCmerge_G_all.bed pGBMmerge_G_all.bed NHA_G_all.bed NPC_G_all.bed 4DNFIYGPDLKF_G_all.bed >G_all_cmpt1.txt
#awk '{print $1"\t"$2"\t"$4"\t"$6"\t"$8"\t"$10"\t"$12}' G_all_cmpt1.txt > G_all_cmpt.txt
#awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5":"$9}' a.bed >b.bed
#bedtools groupby -i b.bed -g 1-4 -c 5 -o collapse >c.bed

#awk '{print $1"\t"$2"\t"$3"\t"$6"\t"$7"\t"$3-$2"\t"$9}' /cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.bed > gencodev38_gene.bed
#sort -nr -k 5 -k 6 gencodev38_gene.bed >gencodev38_gene.bed.sorted1
#awk '!a[$5]++' gencodev38_gene.bed.sorted >gencodev38_gene.bed.sorted2
#sort -k1,1V -k2,2n -k3,3n gencodev38_gene.bed.sorted2 >gencodev38_gene.bed.sorted


awk '{print $1"\t"$2"\t"$3"\t"$6"\t"$7"\t"$3-$2"\t"$9}' /cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.bed |
sort -nr -k 5 -k 6 |
awk '!a[$5]++' |
sort -k1,1V -k2,2n -k3,3n > gencodev38_gene.bed.sorted.new


#awk '{if ($4=="+") {$2=$2; $3=$2+1} else {$2=$3-1; $3=$3}; {print $1"\t"$2"\t"$3"\t"$5"\t"$7}}' gencodev38_gene.bed.sorted >gencodev38_gene.tss
#grep -w "protein_coding"  gencodev38_gene.tss.bed > gencodev38_PCG.tss.bed
grep -w "protein_coding" /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/gencodev38_gene.bed.sorted  > /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/gencodev38_gene_PCG.bed
