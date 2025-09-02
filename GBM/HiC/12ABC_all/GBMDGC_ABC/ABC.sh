#!/bin/bash

#conda activate final-abc-env
# python /cluster/home/futing/software/ABC/src/makeCandidateRegions.py \
# --narrowPeak /cluster/home/futing/Project/GBM/HiC/12ABC_all/U87/atac/peak/mergeU87_atac_peaks.narrowPeak.merged \
# --bam  /cluster/home/futing/Project/GBM/HiC/12ABC_all/U87/atac/bam_files/U87atac_merge.bam \
# --outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes \
# --regions_blocklist /cluster/home/futing/Project/GBM/HiC/12ABC_all/ENCFF356LFX_blacklist_downfromencode.bed \
# --regions_includelist /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \
# --peakExtendFromSummit 250 --nStrongestPeaks 150000

python /cluster/home/futing/software/ABC/src/run.neighborhoods.py \
--candidate_enhancer_regions CandidateRegion/mergeU87_atac_peaks.narrowPeak.merged.candidateRegions.bed \
--H3K27ac /cluster/home/futing/Project/GBM/HiC/12ABC_all/U87/chip/bam_files/SRR5583270.rmdup_sorted.bam \
--ATAC /cluster/home/futing/Project/GBM/HiC/12ABC_all/U87/atac/bam_files/U87atac_merge.bam \
--expression_table /cluster/home/futing/Project/GBM/HiC/12ABC_all/gbm3_tpm_G_clean.txt --chrom_sizes /cluster/home/futing/Project/GBM/HiC/12ABC_all/hg38.chrom.size \
--cellType GBMDGC   --outdir Neighborhoods --qnorm /cluster/home/futing/software/ABC/src/EnhancersQNormRef.K562.txt \
--genes /cluster/home/futing/Project/GBM/HiC/12ABC_all/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.bed \


# ##hic准备好了
# python /cluster/home/futing/software/ABC/src/juicebox_dump.py \
# --hic_file /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/mergeGBM/GBMnonstem/mega/aligned/inter_30.hic \
# --juicebox "java -Xms512m -Xmx2048m -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar" \
# --outdir HiC --chromosomes all


# for chr in 4
# do
# java -Xms512m -Xmx2048m -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar dump observed VC /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/mergeGBM/GBMnonstem/mega/aligned/inter_30.hic  ${chr} ${chr} BP 5000  HiC/chr${chr}/chr${chr}.VCobserved
# java -Xms512m -Xmx2048m -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar dump norm VC /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/mergeGBM/GBMnonstem/mega/aligned/inter_30.hic  ${chr}  BP 5000  HiC/chr${chr}/chr${chr}.VCnorm
# gzip HiC/chr${chr}/chr${chr}.VCobserved
# gzip HiC/chr${chr}/chr${chr}.VCnorm
# done

# python /cluster/home/futing/software/ABC/src/compute_powerlaw_fit_from_hic.py \
# --hicDir HiC --outDir HiC/powerlaw_new/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all

python /cluster/home/futing/software/ABC/src/predict.py \
--enhancers Neighborhoods/EnhancerList.txt --genes Neighborhoods/GeneList.txt \
--HiCdir HiC --chrom_sizes /cluster/home/futing/Project/GBM/HiC/12ABC_all/hg38.chrom.size \
--hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType GBMDGC --outdir Predictions  --make_all_putative 
