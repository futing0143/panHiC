#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBMstem_ABC/test
#python /cluster/home/futing/software/ABC/src/makeCandidateRegions.py \
#--narrowPeak /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/peak/ts543_merge_atac_peaks.narrowPeak.sorted.merged \
#--bam  /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/ts543_merge.bam \
#--outDir test/CandidateRegion --chrom_sizes /cluster/home/futing/software/ABC/reference/chr_sizes \
#--regions_blocklist /cluster/home/futing/Project/GBM/HiC/12ABC_all/ENCFF356LFX_blacklist_downfromencode.bed \
#--regions_includelist /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \
#--peakExtendFromSummit 250 --nStrongestPeaks 150000

python /cluster/home/futing/software/ABC/src/run.neighborhoods.py \
--candidate_enhancer_regions /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBMstem_ABC/test/CandidateRegion/ts543_merge_atac_peaks.narrowPeak.sorted.merged.candidateRegions.bed \
--H3K27ac /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_h3k27ac/bam_files/SRR12056338.rmdup_sorted.bam \
--ATAC /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055979.rmdup_sorted.bam,/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/ts543_atac/bam_files/SRR12055980.rmdup_sorted.bam \
--expression_table /cluster/home/futing/Project/GBM/HiC/12ABC_all/gsc6_tpm_G_clean.txt \
--chrom_sizes /cluster/home/futing/software/ABC/reference/chr_sizes \
--cellType GBMstem \
--outdir test/Neighborhoods \
--qnorm /cluster/home/futing/software/ABC/src/EnhancersQNormRef.K562.txt \
--genes /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \

python /cluster/home/futing/software/ABC/src/predict.py \
--enhancers Neighborhoods/EnhancerList.txt \
--genes Neighborhoods/GeneList.txt \
--HiCdir hic_bedpe --chrom_sizes  /cluster/home/futing/software/ABC/reference/chr_sizes \
--hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType GBMstem \
--outdir test/Predictions  --make_all_putative 
