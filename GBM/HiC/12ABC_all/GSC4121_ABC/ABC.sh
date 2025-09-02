#!/bin/bash

conda activate final-abc-env
python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py \
    --narrowPeak /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/atac_peaks.narrowPeak.sorted \
    --bam  /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/bam_files/SRR21152050.rmdup_sorted.bam \
    --outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes \
    --regions_blocklist /cluster/home/jialu/GBM/HiC/ABC/ENCFF356LFX_blacklist_downfromencode.bed \
    --regions_includelist /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.TSS500bp.bed \
    --peakExtendFromSummit 250 --nStrongestPeaks 150000

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/compute_powerlaw_fit_from_hic.py \
   --hicDir /cluster/home/jialu/GBM/HiC/GSC4121_ABC/hic_bedpe/ \
   --outDir /cluster/home/jialu/GBM/HiC/GSC4121_ABC/hic_bedpe/powerlaw_new/ \
   --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all --hic_type bedpe

##---------------running----------------
python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/run.neighborhoods.py \
    --candidate_enhancer_regions CandidateRegion/atac_peaks.narrowPeak.sorted.candidateRegions.bed \
    --genes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.bed \
    --H3K27ac /cluster/home/jialu/GBM/HiC/GSC4121_ABC/h3k27ac/bam_files/SRR21152089.rmdup_sorted.bam \
    --ATAC /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/bam_files/SRR21152050.rmdup_sorted.bam \
    --expression_table /cluster/home/jialu/GBM/HiC/GSC4121_ABC/GSC_tpm_G1.txt \
    --chrom_sizes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
    --cellType GSC  \
    --outdir Neighborhoods \
    --qnorm /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/EnhancersQNormRef.K562.txt

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/predict.py \
    --enhancers Neighborhoods/EnhancerList.txt --genes Neighborhoods/GeneList.txt \
    --HiCdir hic_bedpe --hic_type bedpe --hic_resolution 5000 \
    --chrom_sizes  /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
    --hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType GSC \
    --outdir Predictions  --make_all_putative --hic_type bedpe
