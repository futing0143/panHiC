###GBM_tumor.cis_eQTL.txt数据在pancanQTL文件夹，snp转为位点的处理过程在anno文件夹

##04 用snp注释loop
awk 'NR > 1 {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$1"_"$2"_"$3"_"$4"_"$5"_"$6"\t"$7"\t"$8"\t"$9"\t"$10}' \
	/cluster/home/tmp/GBM/HiC/10loop/consensus/mid/GBM/GBM_merged.bedpe > GBM-peakachu-10kb-loops.0.95_label.bedpe
pairToBed -a GBM-peakachu-10kb-loops.0.95_label.bedpe -b /cluster/home/tmp/gaorx/GBM/eQTL/anno/snp_gene_hg38.bed \
	>  loop_snp.bedpe ##either- Report overlaps if either end of A overlaps B.

##05 统计
wc -l GBM-peakachu-10kb-loops.0.95_label.bedpe ##70766 loop总数量
awk '{print $7}' /cluster/home/tmp/gaorx/GBM/eQTL/loop_snp.bedpe | sort | uniq -c | sort -nr >loop_stats.txt
wc -l loop_stats.txt ##4598 与eqtl有交集的loop的数量
awk '{print $15}' /cluster/home/tmp/gaorx/GBM/eQTL/loop_snp.bedpe |sort |uniq |wc -l  ##13078 与loop有交集的eqtl数量
awk '{print $4}' snp_gene_hg38.bed |sort |uniq |wc -l ##54223 ##eqtl总数

##06 pcg dedup
grep -w "protein_coding" /cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.bed > gencode.v38.pcg.bed

awk '{print $1"\t"$2"\t"$3"\t"$6"\t"$7"\t"$3-$2"\t"$9}' gencode.v38.pcg.bed |
sort -nr -k 5 -k 6 |
awk '!a[$5]++' |
sort -k1,1V -k2,2n -k3,3n > gencode.v38.pcg.bed.dedup.bed
awk '{if ($4=="+") {$2=$2; $3=$2+1} else {$2=$3-1; $3=$3}; {print $1"\t"$2"\t"$3"\t"$5"\t"$6"\t"$4}}' gencode.v38.pcg.bed.dedup.bed >gencode.v38.pcg.dedup.tss.bed

###+链为TSS直接减去2000bp，-链为Tss直接加上2000bp
bedtools slop  -i gencode.v38.pcg.dedup.tss.bed -g /cluster/home/jialu/genome/hg38.chrom.sizes -l 2000 -r 0 -s > gencode.v38.pcg.dedup.promoter.bed

##07 用promoter注释loop
pairToBed -a loop_snp.bedpe -b gencode.v38.pcg.dedup.promoter.bed > loop_snp_promoter.bedpe

/cluster/home/tmp/gaorx/GBM/eQTL/loop_snp_promoter.bedpe #前11列是loop信息。12-18是eqtl信息，17列不用看，18是beta。19-24是基因的promoter信息。



#----- 0426
pairToBed -a /cluster/home/futing/Project/GBM/eQTL/GBM_loopfil.bedpe \
	-b /cluster/home/futing/Project/GBM/eQTL/anno/snp_gene_hg38.bed > loop_snp_0426.bedpe
