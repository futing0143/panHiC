hicConvertFormat -m GSM4969660_NHA.mcool::resolutions/5000 \
	-o GSM4969660_NHA_5k.ginteractions --inputFormat cool --outputFormat ginteractions
awk -F "\t" '{print 0, $1, $2, 0, 0, $4, $5, 1, $7}' GSM4969660_NHA_5k.ginteractions.tsv \
	> GSM4969660_NHA_5k.ginteractions.tsv.short
sort -k2,2d -k6,6d GSM4969660_NHA_5k.ginteractions.tsv.short \
	> GSM4969660_NHA_5k.ginteractions.tsv.short.sorted

juicer pre -r 10000,20000,50000,100000,250000,500000,1000000 GSM4969660_NHA_5k.ginteractions.tsv.short.sorted \
	GSM4969660_NHA_5k.ginteractions.tsv.short.sorted.hic ~/4DN_iPSc/pipeline/ref/hg38/hg38.chrom.sizes -f 
