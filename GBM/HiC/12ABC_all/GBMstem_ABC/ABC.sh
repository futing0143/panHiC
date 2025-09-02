#!/bin/bash
# cat /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/atac_rep1_peaks.narrowPeak.sorted /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/atac_rep1_peaks.narrowPeak.sorted > /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak
# bedtools sort -faidx /cluster/home/futing/Project/GBM/HiC/12ABC_all/hg38.chrom.size -i /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak > /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak.sorted
# bedtools merge -i /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak.sorted > /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak.sorted.merged
#samtools merge /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/ts543_merge.bam /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055979.rmdup_sorted.bam /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055980.rmdup_sorted.bam
#samtools index /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/ts543_merge.bam

#conda activate final-abc-env
# python /cluster/home/futing/software/ABC/src/makeCandidateRegions.py \
# --narrowPeak /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak.sorted.merged \
# --bam  /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/ts543_merge.bam \
# --outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes \
# --regions_blocklist /cluster/home/futing/Project/GBM/HiC/12ABC_all/ENCFF356LFX_blacklist_downfromencode.bed \
# --regions_includelist /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \
# --peakExtendFromSummit 250 --nStrongestPeaks 150000

# python /cluster/home/futing/software/ABC/src/run.neighborhoods.py \
# --candidate_enhancer_regions CandidateRegion/ts543_merge_atac_peaks.narrowPeak.sorted.merged.candidateRegions.bed \
# --H3K27ac /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_h3k27ac/bam_files/SRR12056338.rmdup_sorted.bam \
# --ATAC /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055979.rmdup_sorted.bam,/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055980.rmdup_sorted.bam \
# --expression_table /cluster/home/futing/Project/GBM/HiC/12ABC_all/gsc6_tpm_G_clean.txt --chrom_sizes /cluster/home/futing/Project/GBM/HiC/12ABC_all/hg38.chrom.size \
# --cellType GBMstem   --outdir Neighborhoods --qnorm /cluster/home/futing/software/ABC/src/EnhancersQNormRef.K562.txt \
# --genes /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \

# #python /cluster/home/futing/software/ABC/src/compute_powerlaw_fit_from_hic.py --hicDir hic_bedpe/ --outDir hic_bedpe/powerlaw/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all --hic_type bedpe


python /cluster/home/futing/software/ABC/src/predict.py \
--enhancers Neighborhoods/EnhancerList.txt --genes Neighborhoods/GeneList.txt \
--HiCdir hic_bedpe --chrom_sizes  /cluster/home/futing/Project/GBM/HiC/12ABC_all/hg38.chrom.size \
--hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType GBMstem --outdir Predictions  --make_all_putative --hic_type bedpe
