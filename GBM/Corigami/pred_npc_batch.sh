#!/bin/bash
#SBATCH -J gbm_predict
#SBATCH --output=./predict_%j.log 
#SBATCH --cpus-per-task=10

source activate /cluster/home/jwj/Software/anaconda/envs/corigami
model_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/model_npc/epoch=78-step=31363.ckpt'
datapath=/cluster/home/futing/Project/GBM/Corigami/mutation_data/PCAWG/GBM_DEL_only.tsv
##进入存储文件夹
cd /cluster/home/futing/Project/GBM/Corigami/result/
tail -n +2 ${datapath} | while IFS=$'\t' read -r sample chr_hg38 start_hg38 end_hg38 rests; do
    if [ ! -d ${sample} ];then
        echo "mkdir ${sample}"
        mkdir ${sample}
    fi
    echo -e "sample is ${sample} \n"
    echo -e "start is ${start_hg38} \n"
    echo -e "end is ${end_hg38} \n"

    if [[ $start_hg38 -le 1000000 ]];then
        start=0
    else
        start=$((${start_hg38} - 1000000))
    fi
    width=$((${end_hg38} - ${start_hg38}))

    echo -e "running corigami-pred of ${sample}_${chr_hg38}_${start_hg38}_${end_hg38}"
    corigami-predict \
    --out /cluster/home/futing/Project/GBM/Corigami/result/${sample}/ \
    --chr $chr_hg38 \
    --celltype "npc" \
    --start $start \
    --model         ${model_path} \
    --seq           "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/dna_sequence/" \
    --ctcf          "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/ctcf_log2fc.bw" \
    --atac          "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/atac.bw"

done