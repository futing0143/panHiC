##修改科学记数法，使用tsv为bed
#for i in SKNSH GSC NPC NHA WTC GBM pGBM
#do
	#awk -F'\t' '{OFS="\t"; if(NR>1) { $2=int($2); $3=int($3); }; print }' ${i}all_sub_compartments.bed >${i}all_sub_compartments.bed1
	#rm ${i}all_sub_compartments.bed
	#mv ${i}all_sub_compartments.bed1 ${i}all_sub_compartments.bed
#done

#for i in SKNSH GSC NPC NHA WTC pGBM
#do
	#intersectBed -a GBMall_sub_compartments.bed -b ${i}all_sub_compartments.bed -wa -wb > GBM2${i}.bed1
	#awk -F'\t' '{print $1,$2,$3,$4,$6,$10,$12}' GBM2${i}.bed1 >GBM2${i}.bed
	#rm GBM2${i}.bed1
	#mv GBM2${i}.bed GBM2${i}.txt
#done

##--------------执行代码------------------
cooler makebins /cluster/home/jialu/genome/hg38_23chrm.sizes 10000 -o 10kbin.txt
for i in GBM GSC NPC NHA WTC pGBM
do
	awk -F'\t' '{OFS="\t"; if(NR>1) { $2=int($2); $3=int($3); }; print }' /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/10k_KR/${i}/sub_compartments/${i}all_sub_compartments.tsv | awk '{print $1":"$2"-"$3"\t"$5}' > ${i}.txt
done

cooler makebins /cluster/home/jialu/genome/hg38_23chrm.sizes 10000 -o 10kbin.txt
awk '{print $1":"$2"-"$3}' 10kbin.txt > 10kbin1.txt
done