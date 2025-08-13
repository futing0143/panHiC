#!/bin/bash
#SBATCH -J non_stem
#SBATCH --nodelist=node3
#SBATCH -p gpu
#SBATCH --output=./%j.log
#SBATCH --cpus-per-task=5
#SBATCH --gres=gpu:1

source activate /cluster/home/jwj/Software/anaconda/envs/corigami
export CUDA_VISIBLE_DEVICES=1
save_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/model_nonstem'
data_root='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data'
corigami-train --save_path ${save_path} \
--data-root ${data_root} \
--assembly hg38 \
--celltype gbm_nonstem \
--patience 100 \
--max-epochs 200 \
--save-top-n 10 \
--num-gpu 1 \
--batch-size 16 \
--num-workers 4