#!/bin/bash
#SBATCH -J gbm_predict
#SBATCH --output=./predict_%j.log 
#SBATCH --cpus-per-task=10

source activate /cluster/home/jwj/Software/anaconda/envs/corigami
model_path='/cluster/home/futing/Project/GBM/Corigami/corigami_data/model_gbm/epoch=91-step=54740.ckpt'
datapath=/cluster/home/futing/Project/GBM/Corigami/mutation_data/PCAWG/GBM_DEL_only.tsv
##进入存储文件夹
cd /cluster/home/futing/Project/GBM/Corigami/result/
while IFS=$'\t' read -r sample chr_hg38 start_hg38 end_hg38
    if [ ! -d ${sample} ];then
        echo "mkdir ${sample}"
        mkdir ${sample}
    fi
    cd ${sample}
    echo "start is ${start_hg38} \n"
    echo "end is ${end_hg38} \n"

    if [[$start_hg38 -le 20000000]];then
        start=0
    else
        start=$((${start_hg38} - 20000000))
    fi
    width=$((${end_hg38} - ${start_hg38}))

    echo "running corigami-edit of ${sample}_$chr_hg38_$start_hg38_$end_hg38"
    corigami-edit \
    --out /cluster/home/futing/Project/GBM/Corigami/${sample}/ \
    --celltype      "gbm" \
    --chr           ${chr_hg38} \
    --start         ${start} \
    --model         ${model_path} \
    --seq           "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/dna_sequence/" \
    --ctcf          "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/ctcf_log2fc.bw" \
    --atac          "/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/atac.bw" \
    --del-start     ${start_hg38} \
    --del-width     ${width} \
    --padding zero #\      #Padding type, either zero or follow. Using zero: the missing region at the end will be padded with zero for ctcf and atac seq, while sequence will be padded with N (unknown necleotide). Using follow: the end will be padded with features in the following region
    #--hide-line     Remove the line showing deletion site
done < "${datapath}"