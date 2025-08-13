#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
mkdir /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/GBM
## Directories to be created and regex strings for listing files
megadir=${topDir}"/mega"
outputdir=${megadir}"/aligned"
tmpdir=${megadir}"/HIC_tmp"
export TMPDIR=${tmpdir}
outfile=${megadir}/lsf.out
#output messages
logdir="$megadir/debug"

# for i in A172 GB176 GB180 GB182 GB183 GB238 H4 SW1088 U87 U118 U251 U343;do
#     mkdir -p GBM/${i}/aligned
#     ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${i}/aligned/merged_nodups.txt \
#         ./GBM/${i}/aligned/merged_nodups.txt
#     ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${i}/aligned/inter.txt \
#         ./GBM/${i}/aligned/inter.txt
# done

# for i in ts543 ts667;do
#     mkdir -p GBM/${i}/aligned
#     ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${i}/mega/aligned/merged_nodups.txt \
#         ./GBM/${i}/aligned/merged_nodups.txt
#     ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${i}/aligned/inter.txt \
#         ./GBM/${i}/aligned/inter.txt
# done

## Directories to be created and regex strings for listing files
topDir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
juiceDir=/cluster/home/futing/software/juicer_CPU
megadir=${topDir}"/mega"
outputdir=${megadir}"/aligned"
tmpdir=${megadir}"/HIC_tmp"
export TMPDIR=${tmpdir}
outfile=${megadir}/lsf.out
#output messages
logdir="$megadir/debug"

#--- start running
merged_count=`find -L ${topDir} | grep merged_nodups.txt | wc -l`
if [ "$merged_count" -lt "1" ]
then
    echo "***! Failed to find at least one merged_nodups files under ${topDir}"
    exit 1
fi

# merged_names=$(find -L ${topDir} | grep merged_nodups.txt.gz | awk '{print "<(gunzip -c",$1")"}' | tr '\n' ' ')
# if [ ${#merged_names} -eq 0 ]
# then
#     merged_names=$(find -L ${topDir} | grep merged_nodups.txt | tr '\n' ' ')
# fi
inter_names=$(find -L ${topDir} | grep inter.txt | tr '\n' ' ')

## Create output directory, exit if already exists
if [[ -d "${outputdir}" ]] && [ -z $final ] && [ -z $postproc ]
then
    echo "***! Move or remove directory \"${outputdir}\" before proceeding."
    exit 1
else
    mkdir -p ${outputdir}
fi

## Create temporary directory
if [ ! -d "$tmpdir" ]; then
    mkdir $tmpdir
    chmod 777 $tmpdir
fi

## Create output directory, used for reporting commands output
if [ ! -d "$logdir" ]; then
    mkdir "$logdir"
    chmod 777 "$logdir"
fi

# Create top statistics file from all inter.txt files found under current dir
awk -f ${juiceDir}/scripts/common/makemega_addstats.awk ${inter_names} > ${outputdir}/inter.txt
echo "(-: Finished creating top stats files."
cp ${outputdir}/inter.txt ${outputdir}/inter_30.txt
# sort --parallel=20 -T ${tmpdir} -m -k2,2d -k6,6d ${merged_names} > ${outputdir}/merged_nodups.txt

/cluster/home/futing/software/juicer-1.6/misc/calculate_map_resolution.sh \
    /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/mega/aligned/merged_nodups.txt \
    /cluster/home/futing/Project/GBM/HiC/02data/02hic/scripts/GBM_1k/50bp_all.txt