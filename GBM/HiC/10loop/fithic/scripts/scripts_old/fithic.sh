#!/bin/bash
juicer_tools_jar=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
DATADIR=/cluster/home/futing/Project/GBM/HiC/10loop/fithic
mkdir -p $DATADIR/outputs
## other parameters described in fit-hi-c.py
noOfBins=200
mappabilityThres=1
noOfPasses=1
res=10000
name=GBM
## upper and lower bounds on mid-range genomic distances 
#distUpThres=5000000
distLowThres=$((res*2))

inI=$DATADIR/${name}/contactCounts
inF=$DATADIR/${name}/fragmentLists
inB=$DATADIR/${name}/biasPerLocus
mkdir -p $inI $inF $inB

# 01 Create FitHiC fragments
source activate ~/anaconda3/envs/hic
python /cluster/home/futing/software/fithic/fithic/utils/createFitHiCFragments-fixedsize.py \
    --chrLens /cluster/home/futing/ref_genome/hg38_24.chrom.sizes \
    --outFile frags_${res}.gz --resolution ${res}

# 02 Create FitHiC contacts
source activate ~/anaconda3/envs/juicer
cut -f1 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes | while read chr;do
    java -Xms16G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
        dump observed NONE /cluster/home/futing/Project/GBM/HiC/02data/02hic/all/${name}.hic \
        ${chr} ${chr} BP 5000 ${inI}/${chr}.VCobserved
    /cluster/home/futing/software/fithic/fithic/utils/createFitHiCContacts-hic.sh ${inI}/${chr}.VCobserved \
        ${chr} ${chr} ${inI}/${chr}.gz 5000
done

source activate ~/anaconda3/envs/hic
find ${inI}/ -name "*.gz" -exec zcat {} + \
    | sort -k1,1 \
    | gzip > ${inI}/${name}.txt.gz

# 03 Create FitHiC bias
python /cluster/home/futing/software/fithic/fithic/utils/HiCKRy.py -i ${inI}/${name}.txt.gz \
    -f frags_${res}.gz -o ${inB}/bias_${res}.gz -x 0.1

# 04 Run FitHiC
fithic -r $res -l $name -i ${inI}/${name}.txt.gz -f frags_${res}.gz -t ${inB}/bias_${res}.gz \
    -b $noOfBins -p $noOfPasses -L $distLowThres -o outputs/${name}.interOnly

sh /cluster/home/futing/software/fithic/fithic/utils/merge-filter.sh \
    ./outputs/${res}/${name}.intraOnly/${name}.spline_pass1.res${res}.significances.txt.gz \
    ${res} ./outputs/${res}/${name}.intraOnly/${name}.merge.bed.gz 0.05 \
    /cluster/home/futing/software/fithic/fithic/utils/ > ./outputs/${res}/${name}.intraOnly/${name}.merge.log
