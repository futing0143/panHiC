#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=10
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/debug/calres-%j.log
#SBATCH -J "calres"

source activate /cluster2/home/futing/miniforge3/envs/juicer

process_one() {
    cancer="$1"
    gse="$2"
    cell="$3"

    dir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"

    logfile="/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/debug/reso_${cancer}_${gse}_${cell}_$(date +%Y%m%d_%H%M%S).log"

    date | tee -a "${logfile}"
    echo -e "${cancer}\t${gse}\t${cell}\n" | tee -a "${logfile}"

    cd "${dir}" || { echo "Cannot enter dir: ${dir}" | tee -a "${logfile}"; return; }

    input_file=""
    temp_file=""

    if [[ -f "${dir}/aligned/merged_nodups.txt" ]]; then
        input_file="${dir}/aligned/merged_nodups.txt"
    elif [[ -f "${dir}/aligned/merged_nodups.txt.gz" ]]; then
        echo "Temporary decompress: ${dir}/aligned/merged_nodups.txt.gz" | tee -a "${logfile}"
        temp_file=$(mktemp)
        gunzip -c "${dir}/aligned/merged_nodups.txt.gz" > "${temp_file}"
        input_file="${temp_file}"
    else
        echo "Error: merged_nodups not found, skip ${cancer} ${gse} ${cell}" | tee -a "${logfile}"
        return
    fi

    /cluster2/home/futing/software/juicer-1.6/misc/calculate_map_resolution.sh \
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
  "/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/reso1219.txt"

# done < <(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/hic/hicdone1012nig.txt | cut -f1-3)

# 第二次计算reso
# grep -w -v -F -f <(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/post/hicdone1012nig.txt | cut -f1-3) \
# 	<(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/post/hicdone1103.txt | cut -f1-3) \
# 	> /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso1103.txt

# 第三次计算
# grep -w -v -F -f <(cut -f1-3 /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/res.txt) \
# <(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/post/hicdone1120.txt | cut -f1-3) \
# > /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/reso1120.txt


# 第四次计算
# grep -w -v -F -f <(cut -f1-3 /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/res.txt) \
# <(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/post/hicdone1124.txt | cut -f1-3) \
# > /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/reso1126.txt

# 第五次计算
# grep -v -w -F -f <(cut -f1-3 /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/res.txt) /cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt \
# 	| cut -f1-3 | grep -v 'PBMC' > /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/reso1210.txt

# 第六次计算
# metafile=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
# grep -w -v -F -f <(cut -f1-3 res.txt) $metafile | grep -v 'PBMC' > reso1219.txt