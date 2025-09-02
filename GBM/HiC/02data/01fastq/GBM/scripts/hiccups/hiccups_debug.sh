#!/bin/bash
source activate ~/anaconda3/envs/juicer
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/
juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"

for name in GB176 GB180 GB182 GB183 GB238;do

    export PATH=/cluster/apps/cuda/11.7/bin:$PATH
    export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
    java -jar ${juicer_tools_path} hiccups --ignore-sparsity ${name}/aligned/inter_30.hic ${name}/aligned/inter_30_loops
    java -jar ${juicer_tools_path} apa ${name}/aligned/inter_30.hic ${name}/aligned/inter_30_loops ${name}/"apa_results"

done

sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
    -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.1.9.9_jcuda.0.8.jar \
    -g hg38 --ignore_sparsity #-i ./aligned/${i}_inter_30.hic


for name in A172 SW1088 U118 U87 U343;do
    mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${name}
    cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_onedir/${name}/aligned/inter_30_loops/* \
        /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${name}
done

for name in ts667 ts543;do
    echo -e "\n$name.....\n"
    hic_file=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ourdata/onedir/${name}/mega/aligned/inter_30.hic
    export PATH=/cluster/apps/cuda/11.7/bin:$PATH
    export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
    java -jar ${juicer_tools_path} hiccups --ignore-sparsity ${hic_file} ${hic_file%.*}"_loops"

    mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${name}
    cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ourdata/onedir/${name}/mega/aligned/inter_30_loops/* \
        /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/${name}
done

echo "Processing P529.SF12794v1-1....."
java -jar ${juicer_tools_path} hiccups --ignore-sparsity /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re/P529.SF12794v1-1/aligned/inter_30.hic \
    /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re/P529.SF12794v1-1/aligned/inter_30_loops
mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/P529.SF12794v1-1
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re/P529.SF12794v1-1/aligned/inter_30_loops/* \
    /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/P529.SF12794v1-1