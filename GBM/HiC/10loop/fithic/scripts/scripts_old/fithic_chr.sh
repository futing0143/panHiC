#!/bin/bash
filelist=$1
res=$2
hicdir=$3
dump=${4:-yes}

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
distUpThres=5000000 #248956422
distLowThres=$((res*2))


#---------------------- run fithic ----------------------#
# 01 Create FitHiC fragments
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate hic
echo -e "Creating FitHiC fragments for $name...\n"
python /cluster/home/futing/software/fithic/fithic/utils/createFitHiCFragments-fixedsize.py \
   --chrLens /cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome \
   --outFile frags_${res}.gz --resolution ${res}


cat ${filelist} | while read name;do
    echo -e "\nProcessing $name...\n"
    inI=$DATADIR/${name}/contactCounts
    inF=$DATADIR/${name}/fragmentLists
    inB=$DATADIR/${name}/biasPerLocus
    mkdir -p $inI $inF $inB

    # 02 Create FitHiC contacts
    if [ $dump == 'yes' ];then
        echo -e "Creating FitHiC contacts for $name...\n"
        cut -f1 /cluster/home/futing/software/juicer_new/restriction_sites/hg38.genome | while read chr;do
            java -Xms16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
                dump observed NONE ${hicdir}/${name}.hic \
                ${chr} ${chr} BP ${res} ${inI}/${chr}.VCobserved
            /cluster/home/futing/software/fithic/fithic/utils/createFitHiCContacts-hic.sh ${inI}/${chr}.VCobserved \
                ${chr} ${chr} ${inI}/${chr}.gz ${res}
        done


        find ${inI} -name "*.gz" -exec zcat {} + \
            | sort -k1,1 \
            | gzip > ${inI}/${name}_${res}.txt.gz
    fi

    # 03 Create FitHiC bias
    echo -e "Creating FitHiC bias for $name...\n"
    python /cluster/home/futing/software/fithic/fithic/utils/HiCKRy.py -i ${inI}/${name}_${res}.txt.gz \
        -f frags_${res}.gz -o ${inB}/bias_${res}.gz -x 0.1

    # 04 Run FitHiC
    fithic -r $res -l $name -i ${inI}/${name}_${res}.txt.gz -f frags_${res}.gz -t ${inB}/bias_${res}.gz \
        -b $noOfBins -p $noOfPasses -L $distLowThres -o outputs/${res}/${name}.intraOnly -v
done

