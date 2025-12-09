#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=10
#SBATCH --output=/cluster2/home/futing/Project/panCancer/GBM/GSE229962/calres-%j.log
#SBATCH -J "calres"

source activate /cluster2/home/futing/miniforge3/envs/juicer

process_one() {
    cell="$1"

    dir="/cluster2/home/futing/Project/panCancer/GBM/GSE229962/${cell}"
	inputdir=/cluster2/home/futing/Project/GBM/HiC/02data/02hic/GBM_mid/5000
    logfile="/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/debug/reso_GBM_GSE229962_${cell}_$(date +%Y%m%d_%H%M%S).log"

    date | tee -a "${logfile}"
    echo -e "GBM\tGSE229962\t${cell}\n" | tee -a "${logfile}"
    cd "${dir}" || { echo "Cannot enter dir: ${dir}" | tee -a "${logfile}"; return; }

    input_file=""
    temp_file=""

    if [[ -f "${inputdir}/${cell}_5000.txt" ]]; then
        input_file="${inputdir}/${cell}_5000.txt"
    elif [[ -f "${inputdir}/${cell}_5000.txt.gz" ]]; then
        echo "Temporary decompress: ${inputdir}/${cell}_5000.txt.gz" | tee -a "${logfile}"
        temp_file=$(mktemp)
        gunzip -c "${inputdir}/${cell}_5000.txt.gz" > "${temp_file}"
        input_file="${temp_file}"
    else
        echo -e "Error: merged_nodups not found, skip GBM\tGSE229962 ${cell}" | tee -a "${logfile}"
        return
    fi

    /cluster2/home/futing/Project/panCancer/GBM/GSE229962/calres.sh \
        "${input_file}" \
        "${dir}/aligned/50bp.txt" \
        >> "${logfile}" 2>&1

    if [[ -n "${temp_file}" && -f "${temp_file}" ]]; then
        rm "${temp_file}"
    fi
}

export -f process_one
readonly PARALLEL_JOBS=6

parallel -j "${PARALLEL_JOBS}" --colsep '\t' \
  --tmpdir /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/debug \
	process_one :::: \
  "/cluster2/home/futing/Project/panCancer/GBM/GSE229962/cell.txt"

