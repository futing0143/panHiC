#!/bin/bash
#SBATCH -J npc
#SBATCH --nodelist=node2
#SBATCH -p gpu
#SBATCH --output=./%j.log
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:3

source activate /cluster/home/jwj/Software/anaconda/envs/corigami
export CUDA_VISIBLE_DEVICES=2,3,4
save_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data'
data_root='/cluster/home/futing/Project/GBM/Corigami/corigami_data/data'
corigami-train --save_path ${save_path} \
--data-root ${data_root} \
--assembly hg38 \
--celltype npc \
--patience 100 \
--max-epochs 200 \
--save-top-n 3 \
--num-gpu 3 \
--batch-size 4 \
--num-workers 8