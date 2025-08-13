#!/bin/bash -l
#SBATCH -p normal
#SBATCH --mem-per-cpu=4G
#SBATCH -o /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm/debug/hiccups_wrap-%j.out
#SBATCH -e /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm/debug/hiccups_wrap-%j.err
#SBATCH -t 7200
#SBATCH --ntasks=1
#SBATCH -J hiccups_wrap
#SBATCH --gres=gpu:1
#load_gpu="export PATH=/cluster/apps/cuda/11.7/bin:$PATH;export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH; CUDA_VISIBLE_DEVICES=2,3"
juiceDir="/cluster/home/futing/software/juicer_slurm"
outputdir="/cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm/aligned"
genomeID="hg38"

export PATH=/cluster/apps/cuda/11.7/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
export CUDA_VISIBLE_DEVICES=0,1
# echo "load: $load_gpu"
date
nvcc -V
# # notok
${juiceDir}/scripts/juicer_hiccups.sh -j ${juiceDir}/scripts/juicer_tools -i $outputdir/inter_30.hic \
    -m ${juiceDir}/references/motif -g $genomeID
# date
# # ok
# java -jar /cluster/home/futing/software/juicer_slurm/scripts/juicer_tools.jar hiccups --ignore-sparsity \
#     /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm/aligned/inter_30.hic \
#     /cluster/home/futing/Project/GBM/HiC/02data/01fastq/Astrocyte_slurm/aligned/inter_30_loops_test

# hic_file_path=$outputdir/inter_30.hic
# java -Djava.awt.headless=true \
#     -Djava.library.path='/cluster/home/futing/software/juicer_slurm/scripts/lib64'\
#     -Ddevelopment=false -jar /cluster/home/futing/software/juicer_slurm/scripts/juicer_tools.jar hiccups --ignore-sparsity \
#     ${hic_file_path} ${hic_file_path%.*}"_loops"