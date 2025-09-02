python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py --narrowPeak /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/atac_peaks.narrowPeak.sorted --bam  /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/bam_files/SRR21152050.rmdup_sorted.bam --outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes --regions_blocklist /cluster/home/jialu/GBM/HiC/ABC/ENCFF356LFX_blacklist_downfromencode.bed --regions_includelist /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.TSS500bp.bed --peakExtendFromSummit 250 --nStrongestPeaks 150000

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/run.neighborhoods.py \
--candidate_enhancer_regions /cluster/home/jialu/GBM/HiC/GBM_ABC/CandidateRegion/merge_atac_peaks.narrowPeak.sorted.candidateRegions.bed \
--genes /cluster/home/jialu/genome/gencode.v38.pcg.bed \
--H3K27ac /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/bam_files/SRR12056338.rmdup_sorted.bam \
--ATAC /cluster/home/jialu/GBM/HiC/ABC/atac_ourGBM/bam_files/SRR12055979.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/ABC/atac_ourGBM/bam_files/SRR12055980.rmdup_sorted.bam \
--expression_table GBM_tpm_avg.txt --chrom_sizes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
--cellType GBM   --outdir Neighborhoods --qnorm /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/EnhancersQNormRef.K562.txt \
--genes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.bed \
