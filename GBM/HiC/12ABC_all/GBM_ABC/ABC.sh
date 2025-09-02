#!/bin/bash
cat /cluster/home/jialu/GBM/HiC/ABC/atac/peak/atac_rep1_peaks.narrowPeak.sorted /cluster/home/jialu/GBM/HiC/ABC/atac/peak/atac_rep2_peaks.narrowPeak.sorted /cluster/home/jialu/GBM/HiC/ABC/U87/atac/atac_rep1_peaks.narrowPeak.sorted /cluster/home/jialu/GBM/HiC/ABC/U87/atac/atac_rep2_peaks.narrowPeak.sorted /cluster/home/jialu/GBM/HiC/ABC/U87/atac/atac_rep3_peaks.narrowPeak.sorted > /cluster/home/jialu/GBM/HiC/GBM_ABC/merge_atac_peaks.narrowPeak
bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i /cluster/home/jialu/GBM/HiC/GBM_ABC/merge_atac_peaks.narrowPeak > /cluster/home/jialu/GBM/HiC/GBM_ABC/merge_atac_peaks.narrowPeak.sorted
bedtools merge -i /cluster/home/jialu/GBM/HiC/GBM_ABC/merge_atac_peaks.narrowPeak.sorted > /cluster/home/jialu/GBM/HiC/GBM_ABC/merge_atac_peaks.narrowPeak.sorted.merged

samtools merge /cluster/home/jialu/GBM/HiC/GBM_ABC/merge.bam /cluster/home/jialu/GBM/HiC/ABC/atac/bam_files/SRR12055979.rmdup_sorted.bam /cluster/home/jialu/GBM/HiC/ABC/atac/bam_files/SRR12055980.rmdup_sorted.bam /cluster/home/jialu/GBM/HiC/ABC/U87/atac/bam_files/SRR8723798.rmdup_sorted.bam /cluster/home/jialu/GBM/HiC/ABC/U87/atac/bam_files/SRR8723799.rmdup_sorted.bam /cluster/home/jialu/GBM/HiC/ABC/U87/atac/bam_files/SRR8723800.rmdup_sorted.bam
samtools index /cluster/home/jialu/GBM/HiC/GBM_ABC/merge.bam


#conda activate final-abc-env
python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py \
--narrowPeak /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/atac_peaks.narrowPeak.sorted \
--bam  /cluster/home/jialu/GBM/HiC/GSC4121_ABC/atac/bam_files/SRR21152050.rmdup_sorted.bam \
--outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes \
--regions_blocklist /cluster/home/jialu/GBM/HiC/ABC/ENCFF356LFX_blacklist_downfromencode.bed \
--regions_includelist /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.TSS500bp.bed \
--peakExtendFromSummit 250 --nStrongestPeaks 150000

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/run.neighborhoods.py \
--candidate_enhancer_regions /cluster/home/jialu/GBM/HiC/GBM_ABC/CandidateRegion/merge_atac_peaks.narrowPeak.sorted.candidateRegions.bed \
--genes /cluster/home/jialu/genome/gencode.v38.pcg.bed \
--H3K27ac /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/bam_files/SRR12056338.rmdup_sorted.bam \
--ATAC /cluster/home/jialu/GBM/HiC/ABC/atac_ourGBM/bam_files/SRR12055979.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/ABC/atac_ourGBM/bam_files/SRR12055980.rmdup_sorted.bam \
--expression_table GBM_tpm_avg.txt --chrom_sizes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
--cellType GBM  \
--outdir Neighborhoods \
--qnorm /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/EnhancersQNormRef.K562.txt \
--genes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.bed \

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/juicebox_dump.py \
--hic_file /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/GBMmerge_5k.hic \
--juicebox "java -Xms512m -Xmx2048m -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar" \
--outdir HiC --chromosomes all


cat ../VC.list | while read i
do
sample=$(echo ${i}|awk '{print $1}')
chr=$(echo ${i}|awk '{print $2}')
java -Xms512m -Xmx2048m -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar dump observed VC ${sample}  ${chr} ${chr} BP 5000  HiC/chr${chr}/chr${chr}.VCobserved
java -Xms512m -Xmx2048m -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar dump norm VC ${sample}  ${chr}  BP 5000  HiC/chr${chr}/chr${chr}.VCnorm
gzip HiC/chr${chr}/chr${chr}.VCobserved
gzip HiC/chr${chr}/chr${chr}.VCnorm
done

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/compute_powerlaw_fit_from_hic.py \
--hicDir HiC --outDir HiC/powerlaw_new/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/predict.py \
--enhancers Neighborhoods/EnhancerList.txt --genes Neighborhoods/GeneList.txt \
--HiCdir HiC --chrom_sizes  /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
--hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType GBM --outdir Predictions  --make_all_putative 
