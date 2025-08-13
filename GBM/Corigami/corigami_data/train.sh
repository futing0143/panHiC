#!/bin/bash
#SBATCH -J gbm
#SBATCH --nodelist=node3
#SBATCH -p gpu
#SBATCH --output=./%j.log
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:2

#module load cuda/11.7
#source /cluster/home/futing/anaconda3/bin/activate corigami
#export CUDA_VISIBLE_DEVICES=0
save_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data'
data_root='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data'
corigami-train --save_path ${save_path} \
--data-root ${data_root} \
--assembly hg38 \
--celltype gbm \
--patience 100 \
--max-epochs 100 \
--save-top-n 3 \
--num-gpu 2 \
--batch-size 4 \
--num-workers 16
