#!/bin/bash

dir=$1
res=${2:-5000} # resolution, default 5000
dump=${3:-yes}  # start from KR if no
x=${4:-0.1}
ischr=${5:-yes} # whether hic startwith chr
postprocess=${6:-no}
name=$(awk -F '/' '{print $NF}' <<< ${dir})

juicer_tools_jar=/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
hicdir=${dir}/aligned/inter_30.hic

if [ -f ${hicdir} ];then
    echo -e "Hic file exists, continue...\n"
else
    echo "Hic file ${hicdir} does not exist."
    exit 1
fi


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

if [[ $postprocess == 'yes' ]];then
    echo -e "------------- Postprocess is yes, skip creating fragments ---------------- \n"
else
	inI=${dir}/anno/fithic/${res}/contactCounts
    inF=${dir}/anno/fithic/${res}/fragmentLists
    inB=${dir}/anno/fithic/${res}/biasPerLocus
    mkdir -p $inI $inF $inB

    echo -e "------------- 01 Creating FitHiC fragments for $name ----------------- \n"
    if [ -f ${inF}/frags_${res}.gz ];then
        echo -e "frags_${res}.gz exists, skip creating fragments\n"
    else
        /cluster2/home/futing/miniforge3/envs/juicer/bin/python /cluster2/home/futing/software/fithic/fithic/utils/createFitHiCFragments-fixedsize.py \
        --chrLens /cluster2/home/futing/ref_genome/hg38.genome \
        --outFile ${inF}/frags_${res}.gz --resolution ${res}
    fi

    # 02 Create FitHiC contacts
    echo -e "------------- 02 Creating FitHiC contacts for $name ---------------\n"
    if [[ $dump != 'no' ]];then
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

    if [ -f ${inI}/${name}_${res}.txt.gz ];then
        echo -e "${inI}/${name}_${res}.txt.gz exists, skip merging dump results...\n"
    else
        # cat dump results into one file
        find ${inI} -name "*.gz" -exec zcat {} + \
        | sort -k1,1 \
        | gzip > ${inI}/${name}_${res}.txt.gz
    fi

    # 03 Create FitHiC bias
    echo -e "------------- 03 Creating FitHiC bias for $name ------------- \n"
    if [ -f "${inB}/bias_${res}_${x}.gz" ];then
        echo -e "${inB}/bias_${res}_${x}.gz exists, skip creating bias\n"
    else
        which python
        /cluster2/home/futing/miniforge3/envs/juicer/bin/python /cluster2/home/futing/software/fithic/fithic/utils/HiCKRy.py -i ${inI}/${name}_${res}.txt.gz \
            -f ${inF}/frags_${res}.gz -o ${inB}/bias_${res}_${x}.gz -x ${x}
    fi

    # 04 Run FitHiC
    echo -e "------------- 04 Running fithic for $name ------------- \n"
    fithic -r $res -l $name -i ${inI}/${name}_${res}.txt.gz -f ${inF}/frags_${res}.gz -t ${inB}/bias_${res}_${x}.gz \
        -b $noOfBins -p $noOfPasses -L $distLowThres -U $distUpThres \
		-o ${dir}/anno/fithic/outputs/${res}/${name}.intraOnly -v
fi

# 05 Postprocess

echo -e "------------ 05 Postprocessing ${name} at ${res} -------------------\n"
if [ -f ./outputs/${res}/${name}.intraOnly/${name}.merge.bed.gz ];then
    echo -e "./outputs/${res}/${name}.intraOnly/${name}.merge.bed.gz exists, skip postprocessing\n"
else
    sh /cluster2/home/futing/software/fithic/fithic/utils/merge-filter-parallelized.sh \
        ./outputs/${res}/${name}.intraOnly/${name}.spline_pass1.res${res}.significances.txt.gz \
        ${res} ./outputs/${res}/${name}.intraOnly/ 0.05 \
        /cluster2/home/futing/software/fithic/fithic/utils/ > ./outputs/${res}/${name}.intraOnly/${name}.merge.log
fi

reso=$((res/2))
zcat ./outputs/${res}/${name}.intraOnly/${name}.merge.bed.gz | \
    awk -v reso=$reso 'BEGIN{FS=OFS="\t"}{print $1,int($2)-reso,int($2)+reso,$3,int($4)-reso,int($4)+reso,$5,$6,$7}' \
    > ./outputs/${res}/${name}.intraOnly/${name}.fithic.bed

if [ $? -eq 0 ]
then
    echo -e "\nFithic finished successfully for ${name} at ${res}!!!\n"
else
    echo "***! Problem while running Fithic for ${name} at ${res} !***";
    exit 1
fi


