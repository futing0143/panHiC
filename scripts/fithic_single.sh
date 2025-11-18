#!/bin/bash

dir=$1
res=${2:-5000} # resolution, default 5000
dump=${3:-yes}  # start from KR if no
x=${4:-0.1}
usehicKR=${5:-no}
ischr=${6:-yes} # whether hic startwith chr
postprocess=${7:-no}
name=$(basename "${dir%/}")

set -euo pipefail
juicer_tools_jar=/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
hicdir="${dir}/aligned/inter_30.hic"

if [ -f "${hicdir}" ];then
    echo -e "Hic file exists, continue...\n"
else
    echo "Hic file ${hicdir} does not exist."
    exit 1
fi
check_gz_nonempty () {
	local f="$1"
	[[ -f "$f" ]] && [[ $(zcat "$f" 2>/dev/null | wc -l) -gt 0 ]]
}


mkdir -p ${dir}/anno/fithic/outputs
cd ${dir}/anno/fithic
## other parameters described in fit-hi-c.py
noOfBins=50
mappabilityThres=1
noOfPasses=1
## upper and lower bounds on mid-range genomic distances 
distUpThres=5000000     #248956422
distLowThres=$((res*2))


#---------------------- run fithic ----------------------#
# 01 Create FitHiC fragments
source activate /cluster2/home/futing/miniforge3/envs/juicer

if [[ "$postprocess" == 'yes' ]];then
    echo -e "------------- Postprocess is yes, skip creating fragments ---------------- \n"
else
	inI=${dir}/anno/fithic/${res}/contactCounts
    inF=${dir}/anno/fithic/${res}/fragmentLists
    inB=${dir}/anno/fithic/${res}/biasPerLocus
    mkdir -p $inI $inF $inB

    echo -e "------------- 01 Creating FitHiC fragments for $name ----------------- \n"
    if check_gz_nonempty ${inF}/frags_${res}.gz;then
        echo -e "frags_${res}.gz exists, skip creating fragments\n"
    else
        /cluster2/home/futing/miniforge3/envs/juicer/bin/python /cluster2/home/futing/software/fithic/fithic/utils/createFitHiCFragments-fixedsize.py \
        --chrLens /cluster2/home/futing/ref_genome/hg38.genome \
        --outFile ${inF}/frags_${res}.gz --resolution ${res}
    fi

    # 02 Create FitHiC contacts
    echo -e "------------- 02 Creating FitHiC contacts for $name ---------------\n"
	if ! check_gz_nonempty ${inI}/${name}_${res}.txt.gz;then
		if [[ "$dump" != 'no' ]];then
			if [[ $ischr != 'no' ]];then
				echo -e "Using chr...\n"
				cut -f1 /cluster2/home/futing/ref_genome/hg38.genome | while read chr;do
					java -Xms16G -jar /cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
						dump observed NONE ${hicdir} \
						${chr} ${chr} BP ${res} ${inI}/${chr}.VCobserved
					/cluster2/home/futing/software/fithic/fithic/utils/createFitHiCContacts-hic.sh ${inI}/${chr}.VCobserved \
						${chr} ${chr} ${inI}/${chr}.gz ${res}
				done
			else
				echo -e "Not using chr...\n"
				cut -f1 /cluster2/home/futing/ref_genome/hg38_24_nochr.chrom.sizes | while read chr;do
					java -Xms16G -jar /cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
						dump observed NONE ${hicdir} \
						${chr} ${chr} BP ${res} ${inI}/chr${chr}.VCobserved
					/cluster2/home/futing/software/fithic/fithic/utils/createFitHiCContacts-hic.sh ${inI}/chr${chr}.VCobserved \
						chr${chr} chr${chr} ${inI}/chr${chr}.gz ${res}
				done
			fi
		else
			echo -e "Skip dumping...\n"
		fi
	fi

    if check_gz_nonempty ${inI}/${name}_${res}.txt.gz;then
        echo -e "${inI}/${name}_${res}.txt.gz exists, skip merging dump results...\n"
    else
		if [ -f "${inI}/${name}_${res}.txt.gz" ];then
			rm ${inI}/${name}_${res}.txt.gz
		fi
        # cat dump results into one file
        find ${inI} -name "*[0-9].gz" -exec zcat {} + \
        | sort -k1,1 -k2,2n -k3,3 -k4,4n \
        | gzip > ${inI}/${name}_${res}.txt.gz
    fi

    # 03 Create FitHiC bias
    echo -e "------------- 03 Creating FitHiC bias for $name ------------- \n"
    if check_gz_nonempty "${inB}/bias_${res}_${x}.gz" || check_gz_nonempty "${inB}/bias_juicer_${res}.txt.gz";then
        echo -e "${inB}/bias_${res}_${x}.gz exists, skip creating bias\n"
    elif [[ "$usehicKR" == 'no' ]];then
       	echo -e "Using fithic KR...\n"
        /cluster2/home/futing/miniforge3/envs/juicer/bin/python /cluster2/home/futing/software/fithic/fithic/utils/HiCKRy.py -i ${inI}/${name}_${res}.txt.gz \
            -f ${inF}/frags_${res}.gz -o ${inB}/bias_${res}_${x}.gz -x ${x}
    elif [[ "$usehicKR" == 'yes' ]];then
       	echo -e "Using juicer KR...\n"
		/cluster2/home/futing/Project/panCancer/scripts/KR_single.sh ${dir} ${res}
	fi

	for f in \
		"${inI}/${name}_${res}.txt.gz" \
		"${inF}/frags_${res}.gz"
	do
		! check_gz_nonempty $f && echo "$f missing" && exit 1
	done
	if ! check_gz_nonempty "${inB}/bias_juicer_${res}.txt.gz" && ! check_gz_nonempty "${inB}/bias_${res}_${x}.gz"; then
		echo "bias 文件缺失或为空" && exit 1
	fi

    # 04 Run FitHiC
    echo -e "------------- 04 Running fithic for $name ------------- \n"
	outputfile=${dir}/anno/fithic/outputs/${res}/${name}_${x}.intraOnly/${name}.spline_pass1.res${res}.significances.txt.gz
	if check_gz_nonempty "${outputfile}";then
		echo "${outputfile} exists ..."
	else
		if [[ "$usehicKR" == 'no' ]];then
			echo -e "Running fithic using fithic KR..."
			fithic -r $res -l $name -i ${inI}/${name}_${res}.txt.gz -f ${inF}/frags_${res}.gz -t ${inB}/bias_${res}_${x}.gz \
				-b $noOfBins -p $noOfPasses -L $distLowThres -U $distUpThres \
				-o ${dir}/anno/fithic/outputs/${res}/${name}_${x}.intraOnly -v
		elif [[ "$usehicKR" == 'yes' ]];then
			echo -e "Running fithic using juicer KR...\n"
			fithic -r $res -l $name -i ${inI}/${name}_${res}.txt.gz -f ${inF}/frags_${res}.gz -t ${inB}/bias_juicer_${res}.txt.gz \
				-b $noOfBins -p $noOfPasses -L $distLowThres -U $distUpThres \
				-o ${dir}/anno/fithic/outputs/${res}/${name}_${x}.intraOnly -v
		fi
	fi
fi


# 05 Postprocess

echo -e "------------ 05 Postprocessing ${name} at ${res} -------------------\n"
if [ -f "./outputs/${res}/${name}_${x}.intraOnly/${name}.merge.bed.gz" ];then
    echo -e "./outputs/${res}/${name}_${x}.intraOnly/${name}.merge.bed.gz exists, skip postprocessing\n"
else
	jid=$(sh /cluster2/home/futing/software/fithic/fithic/utils/merge-filter-parallelized.sh \
		./outputs/${res}/${name}_${x}.intraOnly/${name}.spline_pass1.res${res}.significances.txt.gz \
		${res} ./outputs/${res}/${name}_${x}.intraOnly/ 0.05 \
		/cluster2/home/futing/software/fithic/fithic/utils/ 2>&1 | tee ./outputs/${res}/${name}_${x}.intraOnly/${name}.merge.log | tail -n 1)

fi


if [ -s "./outputs/${res}/${name}_${x}.intraOnly/${name}.fithic.bed" ];then
	echo "./outputs/${res}/${name}_${x}.intraOnly/${name}.fithic.bed exits! Exiting the scripts!"
else
	if [ -z "${jid}" ]; then
		echo "No job ID found for merging and filtering step. Merging the files directly..."
	else
		# 等待 job 完成
		echo "Waiting for job ${jid} to finish..."
		while squeue -j "${jid}" > /dev/null 2>&1 && squeue -j "${jid}" | grep -q "${jid}"; do
			sleep 60  # 每60秒检查一次
		done
		echo "All sub-jobs for ${jid} completed."
	fi
	echo -e "Creating fithic bed file for ${name} at ${res}...\n"
	> "./outputs/${res}/${name}_${x}.intraOnly/${name}.fithic.bed"
	reso=$((res/2))
	cut -f1 ./outputs/${res}/${name}_${x}.intraOnly/chromosomes.used | while read -r chr; do
		zcat ./outputs/${res}/${name}_${x}.intraOnly/${chr}/postmerged_fithic_${chr}.gz |
			awk -v reso=$reso 'BEGIN{FS=OFS="\t"}NR>1{print $1,int($2)-reso,int($2)+reso,$3,int($4)-reso,int($4)+reso,$5,$6,$7}' \
			>> "./outputs/${res}/${name}_${x}.intraOnly/${name}.fithic.bed"
	done
fi


if [ $? -eq 0 ]
then
    echo -e "\nFithic finished successfully for ${name} at ${res}!!!\n"
else
    echo "***! Problem while running Fithic for ${name} at ${res} !***";
    exit 1
fi


