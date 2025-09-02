#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/test
#python /cluster/home/futing/software/ABC/src/makeCandidateRegions.py \
#--narrowPeak /cluster/home/futing/Project/GBM/HiC/12ABC_all/GSC4121_ABC/atac/atac_peaks.narrowPeak.sorted \
#--bam  /cluster/home/futing/Project/GBM/HiC/12ABC_all/GSC4121_ABC/atac/bam_files/SRR21152050.rmdup_sorted.bam \
#--outDir CandidateRegion --chrom_sizes /cluster/home/futing/software/ABC/reference/chr_sizes \
#--regions_blocklist /cluster/home/futing/Project/GBM/HiC/12ABC_all/ENCFF356LFX_blacklist_downfromencode.bed \
#--regions_includelist /cluster/home/futing/software/ABC/reference/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \
#--peakExtendFromSummit 250 --nStrongestPeaks 150000

python /cluster/home/futing/software/ABC/src/run.neighborhoods.py \
--candidate_enhancer_regions ./CandidateRegion/atac_peaks.narrowPeak.sorted.candidateRegions.bed \
--H3K27ac /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_h3k27ac/bam_files/SRR12056338.rmdup_sorted.bam \
--ATAC /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055980.rmdup_sorted.bam,/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055979.rmdup_sorted.bam \
--expression_table ../GBM_tpm_avg.txt \
--chrom_sizes /cluster/home/futing/software/ABC/reference/chr_sizes \
--cellType GBM   \
--outdir Neighborhoods \
--qnorm /cluster/home/futing/software/ABC/src/EnhancersQNormRef.K562.txt \
--genes /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \
