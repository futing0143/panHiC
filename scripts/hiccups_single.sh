#!/bin/bash
dir=$1
hicdir=${dir}/aligned/inter_30.hic
export PATH=/cluster/apps/cuda/10.2/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/10.2/lib64:$LD_LIBRARY_PATH
juicer_tools_path=/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools
juicer_tools_jar="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"

cd ${dir}/anno/hiccups
nvcc -V


# ---- Checking Norm status ----
check_norm () {
  local reso=$1
  local hicfile=$2
  java -jar "$juicer_tools_jar" dump norm KR "${hicfile}" chr1 BP "$reso" 2>&1 | head -n 20
}
need_addnorm=0
for reso in 5000 10000 25000; do
    echo "[INFO] Checking KR normalization status at BP_${reso}..."
    
    if check_norm ${reso} ${hicdir} | grep -q "Norm not available"; then
        echo "[WARN] KR missing at BP_${reso}..."
        need_addnorm=1
    else
        echo "[OK] KR already available at BP_${reso}."
    fi
done

if [[ "$need_addnorm" -eq 1 ]]; then
  echo "[WARN] Running addNorm on ${hic} ..."
  java -jar "$juicer_tools_jar" addNorm -j 10 "${hicdir}"
fi

if [ ! -s "${dir}/anno/hiccups/merged_loops.bedpe" ];then
    echo -e "\n[$(date)] HiCCUPS:\n"
    if hash nvcc 2>/dev/null 
    then 
        ${juicer_tools_path} hiccups --ignore-sparsity ${hicdir} ${dir}/anno/hiccups
        if [ $? -ne 0 ]; then
        echo "***! Problem while running HiCCUPS";
        exit 1
        fi
    else 
        echo "GPUs are not installed so HiCCUPs cannot be run";
    fi
fi

if [ -s "${dir}/anno/hiccups/merged_loops.bedpe" ]
then
    echo -e "\n[$(date)] APA:\n"
    ${juicer_tools_path} apa ${hicdir} ${dir}/anno/hiccups "apa_results"
else
  # if loop lists do not exist but Juicer Tools didn't return an error, likely 
  # too sparse
    echo -e "\n(-: Postprocessing successfully completed, maps too sparse to annotate or GPUs unavailable (-:"
fi



# juicer_tools_path="/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
# hicfile="${hicdir}/aligned/inter_30.hic"

# sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
#     -j ${juicer_tools_path} \
#     -i ${hicfile} -g hg38