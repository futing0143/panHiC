#!/bin/bash
filelist=$1

juicer_tools_jar=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
DATADIR=/cluster/home/futing/Project/GBM/HiC/10loop/fithic

mkdir -p $DATADIR/outputs
## other parameters described in fit-hi-c.py
noOfBins=200
mappabilityThres=1
noOfPasses=1
res=5000
## upper and lower bounds on mid-range genomic distances 
#distUpThres=5000000
distLowThres=$((res*2))

# 01 Create FitHiC fragments
source activate ~/anaconda3/envs/hic
echo -e "Creating FitHiC fragments for $name...\n"
python /cluster/home/futing/software/fithic/fithic/utils/createFitHiCFragments-fixedsize.py \
    --chrLens /cluster/home/futing/ref_genome/hg38_24.chrom.sizes \
    --outFile frags_${res}.gz --resolution ${res}


cat ${filelist} | while read name;do
    echo -e "\nProcessing $name...\n"
     
    inI=$DATADIR/${name}/contactCounts
    inF=$DATADIR/${name}/fragmentLists
    inB=$DATADIR/${name}/biasPerLocus
    mkdir -p $inI $inF $inB

    # 02 Create FitHiC contacts
    source activate ~/anaconda3/envs/juicer
    echo -e "Creating FitHiC contacts for $name...\n"
    cut -f1 /cluster/home/futing/ref_genome/hg38_24_nochr.chrom.sizes | while read chr;do
        java -Xms16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
            dump observed NONE /cluster/home/tmp/GBM/HiC/02data/02hic/GBM/${name}.hic \
            ${chr} ${chr} BP ${res} ${inI}/chr${chr}.VCobserved
        /cluster/home/futing/software/fithic/fithic/utils/createFitHiCContacts-hic.sh ${inI}/chr${chr}.VCobserved \
            chr${chr} chr${chr} ${inI}/chr${chr}.gz ${res}
    done

    source activate ~/anaconda3/envs/hic
    find ${inI} -name "*.gz" -exec zcat {} + \
        | sort -k1,1 \
        | gzip > ${inI}/${name}_${res}.txt.gz

    # 03 Create FitHiC bias
    echo -e "Creating FitHiC bias for $name...\n"
    python /cluster/home/futing/software/fithic/fithic/utils/HiCKRy.py -i ${inI}/${name}_${res}.txt.gz \
        -f frags_${res}.gz -o ${inB}/bias_${res}.gz

    # 04 Run FitHiC
    fithic -r $res -l $name -i ${inI}/${name}_${res}.txt.gz -f frags_${res}.gz -t ${inB}/bias_${res}.gz \
        -b $noOfBins -p $noOfPasses -L $distLowThres -o outputs/${name}_${res}.intraOnly
done

