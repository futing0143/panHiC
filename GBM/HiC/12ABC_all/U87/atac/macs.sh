samtools merge bam_files/U87atac_merge.bam bam_files/SRR8723798.rmdup_sorted.bam bam_files/SRR8723799.rmdup_sorted.bam bam_files/SRR8723800.rmdup_sorted.bam
samtools index bam_files/U87atac_merge.bam

for i in SRR8723798 SRR8723799 SRR8723800
do
macs2 callpeak -t bam_files/${i}.rmdup_sorted.bam -n ${i} -f BAM -g hs -p .1 --call-summits --outdir peak 
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i peak/${i}_peaks.narrowPeak > peak/${i}_peaks.narrowPeak.sorted
done

cat peak/SRR8723798_peaks.narrowPeak.sorted peak/SRR8723799_peaks.narrowPeak.sorted peak/SRR8723800_peaks.narrowPeak.sorted > peak/mergeU87_atac_peaks.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i peak/mergeU87_atac_peaks.narrowPeak > peak/mergeU87_atac_peaks.narrowPeak.sorted
bedtools merge -i peak/mergeU87_atac_peaks.narrowPeak.sorted > peak/mergeU87_atac_peaks.narrowPeak.merged
