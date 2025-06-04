#!/bin/bash
hicdir=$1
export PATH=/cluster/apps/cuda/10.2/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/10.2/lib64:$LD_LIBRARY_PATH

nvcc -V
# juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
# hicfile="${hicdir}/aligned/inter_30.hic"

# sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
#     -j ${juicer_tools_path} \
#     -i ${hicfile} -g hg38


juicer_tools_jar="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
echo -e "\nHiCCUPS:\n"
if hash nvcc 2>/dev/null 
then 
    java -jar ${juicer_tools_jar} hiccups --restrict -r 10000 ${hicdir} ${hicdir%.*}"_loops"
    if [ $? -ne 0 ]; then
    echo "***! Problem while running HiCCUPS";
    exit 1
    fi
else 
    echo "GPUs are not installed so HiCCUPs cannot be run";
fi