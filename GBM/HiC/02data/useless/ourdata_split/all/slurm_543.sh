#!/bin/bash
#SBATCH -J 543
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=ts543.out
#SBATCH --error=ts543.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address


source activate /cluster/home/jialu/miniconda3/envs/juicer/
sh gener_hic_543.sh 
#ips/SRR13510887文件夹下跑
#nohup /cluster/home/jialu/ips/pipeline/mdg_pipe.sh SRR8932545 -s none -g hg38 -D /cluster/home/jialu/ips  >> /cluster/home/jialu/ips/SRR8932545/out.txt 2>&1 &
