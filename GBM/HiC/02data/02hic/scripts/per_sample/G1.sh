#!/bin/bash

juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"

java -Xmx16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar pre \
    -j 20 --threads 30 -r 5000,10000,25000 -d ./5000/G1_5000.txt \
    ./all/G1_new.hic /cluster/home/futing/ref_genome/hg38.chrom.sizes
java -Xmx16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar AddNorm \
    -j 20 -r 5000 ./all/G1_new.hic 

touch inter_30.txt
ligation="'(GAATAATC|GAATACTC|GAATAGTC|GAATATTC|GAATGATC|GACTAATC|GACTACTC|GACTAGTC|GACTATTC|GACTGATC|GAGTAATC|GAGTACTC|GAGTAGTC|GAGTATTC|GAGTGATC|GATCAATC|GATCACTC|GATCAGTC|GATCATTC|GATCGATC|GATTAATC|GATTACTC|GATTAGTC|GATTATTC|GATTGATC)'" 
site_file="/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt"
/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools LibraryComplexity $outputdir \
    inter.txt >> $outputdir/inter.txt #9-12
/cluster/home/futing/software/juicer_CPU/scripts/common/statistics.pl -s $site_file -l $ligation \
    -o ./inter.txt -q 1 ./5000/G1_5000.txt #13-22

echo -e "\nRunning HiCCUPS for G1...\n"
export PATH=/cluster/apps/cuda/11.7/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
java -jar ${juicer_tools_path} hiccups ./all/G1_new.hic ./all/G1_new_loops
java -jar ${juicer_tools_path} apa ./all/G1_new.hic ./all/G1_new_loops "apa_results"
