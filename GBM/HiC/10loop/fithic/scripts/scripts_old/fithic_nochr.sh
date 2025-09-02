#!/bin/bash
filelist=$1
res=$2
hicdir=$3
x=${4:-0.1}
juicer_tools_jar=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
DATADIR=/cluster/home/futing/Project/GBM/HiC/10loop/fithic/${res}
cd /cluster/home/futing/Project/GBM/HiC/10loop/fithic
mkdir -p outputs/${res}
mkdir -p ${DATADIR}
## other parameters described in fit-hi-c.py
noOfBins=50
mappabilityThres=1
noOfPasses=1
## upper and lower bounds on mid-range genomic distances 
distUpThres=5000000 #248956422 2000000
distLowThres=$((res*2))
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic

#---------------------- run fithic ----------------------#
# 01 Create FitHiC fragments
echo -e "Creating FitHiC fragments for $name...\n"
python /cluster/home/futing/software/fithic/fithic/utils/createFitHiCFragments-fixedsize.py \
    --chrLens /cluster/home/futing/ref_genome/hg38_24.chrom.sizes \
    --outFile frags_${res}.gz --resolution ${res}

if [ -f ${filelist} ];then
    echo "File list exists."
else
    echo "File ${filelist} list does not exist."
    exit 1
fi

cat ${filelist} | while read name;do
    echo -e "\nProcessing $name...\n"
    inI=$DATADIR/${name}/contactCounts
    inF=$DATADIR/${name}/fragmentLists
    inB=$DATADIR/${name}/biasPerLocus
    mkdir -p $inI $inF $inB

    # 02 Create FitHiC contacts
    echo -e "Creating FitHiC contacts for $name...\n"
    cut -f1 /cluster/home/futing/ref_genome/hg38_24_nochr.chrom.sizes | while read chr;do
        java -Xms16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
            dump observed NONE ${hicdir}/${name}.hic \
            ${chr} ${chr} BP ${res} ${inI}/chr${chr}.VCobserved
        /cluster/home/futing/software/fithic/fithic/utils/createFitHiCContacts-hic.sh ${inI}/chr${chr}.VCobserved \
            chr${chr} chr${chr} ${inI}/chr${chr}.gz ${res}
    done

    find ${inI} -name "*.gz" -exec zcat {} + \
        | sort -k1,1 \
        | gzip > ${inI}/${name}_${res}.txt.gz

    # 03 Create FitHiC bias
    echo -e "Creating FitHiC bias for $name...\n"
    python /cluster/home/futing/software/fithic/fithic/utils/HiCKRy.py -i ${inI}/${name}_${res}.txt.gz \
        -f frags_${res}.gz -o ${inB}/bias_${res}.gz -x ${x}

    # 04 Run FitHiC
    fithic -r $res -l $name -i ${inI}/${name}_${res}.txt.gz -f frags_${res}.gz -t ${inB}/bias_${res}.gz \
        -b $noOfBins -p $noOfPasses -L $distLowThres -U $distUpThres -o outputs/${res}/${name}.intraOnly -v
done

