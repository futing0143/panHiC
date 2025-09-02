cat /cluster/home/jialu/GBM/HiC/NPC_ABC/atac/atac_rep1_peaks.narrowPeak /cluster/home/jialu/GBM/HiC/NPC_ABC/atac/atac_rep2_peaks.narrowPeak /cluster/home/jialu/GBM/HiC/NPC_ABC/atac/atac_rep3_peaks.narrowPeak > NPC.atac.merge.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i NPC.atac.merge.narrowPeak > NPC.atac.merge.narrowPeak.sorted
bedtools merge -i NPC.atac.merge.narrowPeak.sorted > NPC.atac.merge.narrowPeak.sorted.merged

samtools merge NPC_atac_merge.bam /cluster/home/jialu/GBM/HiC/NPC_ABC/atac/bam_files/SRR16242098.rmdup_sorted.bam /cluster/home/jialu/GBM/HiC/NPC_ABC/atac/bam_files/SRR16242099.rmdup_sorted.bam /cluster/home/jialu/GBM/HiC/NPC_ABC/atac/bam_files/SRR16242100.rmdup_sorted.bam
samtools index NPC_atac_merge.bam
