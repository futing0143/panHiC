#!/bin/bash
resolutions=(5000 10000 50000 100000 500000 1000000)
id=(iPSC_new NPC_new)
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/
result_mcool=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/
result_cool=/cluster/home/futing/Project/GBM/HiC/02data/03cool
result_cool_KR=/cluster/home/futing/Project/GBM/HiC/02data/03cool_KR

for name in "${id[@]}"
do
    date
    #name=$(echo $line | cut -d'/' -f10)
    line="./$name/aligned/inter_30.hic"
    echo -e '\n'Processing $line...'\n'
    hicConvertFormat -m $line --inputFormat hic --outputFormat cool -o $result_mcool/$name.mcool
    # 01 hic 2 mcool
    for resolution in "${resolutions[@]}";do
        cooler balance $result_mcool/${name}.mcool::resolutions/${resolution}
    done
    #02 mcool 2 cool 2 KR
    for resolution in "${resolutions[@]}";do
        python /cluster/home/tmp/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py $result_mcool/${name}.mcool::resolutions/${resolution}
        echo "Processing ${name} at ${resolution}..."
        cooler dump --join ${result_mcool}/${name}.mcool::resolutions/${resolution} | \
        cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${resolution} \
        - $result_cool/${resolution}/${name}_${resolution}.cool
        cooler balance $result_cool/${resolution}/${name}_${resolution}.cool
    done

    # 03 cool 2 KR
    for resolution in "${resolutions[@]}";do
        if [ ! -d /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/${resolution} ]; then
            mkdir /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/${resolution}
        fi
        
        echo -e "\n Processing $name at ${resolution} resolution \n"
        hicCorrectMatrix correct --matrix  ${result_cool}/${resolution}/${name}_${resolution}.cool  \
        --correctionMethod KR --outFileName  ${result_cool_KR}/${resolution}/$name.${resolution}.KR.cool \
        --chromosomes chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX 
    done

    date
done

