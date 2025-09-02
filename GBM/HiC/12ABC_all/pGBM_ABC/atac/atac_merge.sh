cat filename.txt | while read i
do
macs2 callpeak -t bam_files/${i}.rmdup_sorted.bam -n atac_${i} -f BAM -g hs -p .1 --call-summits --outdir peak 
done


cat peak/atac_SRR13252800_peaks.narrowPeak peak/atac_SRR13252801_peaks.narrowPeak peak/atac_SRR13252802_peaks.narrowPeak peak/atac_SRR13252803_peaks.narrowPeak peak/atac_SRR13252804_peaks.narrowPeak peak/atac_SRR13252805_peaks.narrowPeak > pHGG.atac.merge.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i pHGG.atac.merge.narrowPeak > pHGG.atac.merge.narrowPeak.sorted
bedtools merge -i pHGG.atac.merge.narrowPeak.sorted > pHGG.atac.merge.narrowPeak.sorted.merged

samtools merge pHGG_atac_merge.bam bam_files/SRR13252800.rmdup_sorted.bam bam_files/SRR13252801.rmdup_sorted.bam bam_files/SRR13252802.rmdup_sorted.bam bam_files/SRR13252803.rmdup_sorted.bam bam_files/SRR13252804.rmdup_sorted.bam bam_files/SRR13252805.rmdup_sorted.bam
samtools index pHGG_atac_merge.bam
