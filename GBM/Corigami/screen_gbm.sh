#!/bin/bash
#SBATCH -J gbm_predict
#SBATCH --output=./predict_%j.log 
#SBATCH --cpus-per-task=10
source activate /cluster/home/jwj/Software/anaconda/envs/corigami
model_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/model_gbm/epoch=84-step=50575.ckpt'
chr_hg38='chr1'
start_hg38='62637331'
end_hg38='62640275'

if [[ $start_hg38 -le 1000000 ]];then
    start=0
else
    start=$((${start_hg38} - 1000000))
    end=$((${end_hg38} + 1000000))
fi



corigami-screen --out /cluster/home/futing/Project/GBM/Corigami \
--chr "chr1" \
--celltype "gbm" \
--model ${model_path} \
--seq "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/dna_sequence/" \
--ctcf "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/ctcf_log2fc.bw" \
--atac "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/atac.bw" \
--screen-start $start \
--screen-end $end \
--perturb-width 1000 \
--step-size 1000 \
--plot-impact-score \
--save-pred --save-perturbation --save-diff --save-bedgraph
