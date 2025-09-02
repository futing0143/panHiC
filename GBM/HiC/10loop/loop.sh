#!/bin/bash

# 最早一版，给name，跑6种分析

queue="normal"
queue_time="2880"
debugdir=/cluster/home/futing/Project/GBM/HiC/10loop
name=OPC
peakachu=${1}
mustache=${2}
cooltools=${3}
fithic=${4}
homer=${5}

# peakachu
if [ -z $peakachu ];then
    peakachu=0
else
jid=`sbatch <<- PEAKACHU | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH -o $debugdir/peakachu/debug/$name-%j.log
#SBATCH -e $debugdir/peakachu/debug/$name-%j.err
#SBATCH -J "${name}_peakachu"
    
date
sh /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu_single.sh 10000 $name
#sh /cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu_single.sh 5000 $name
date
PEAKACHU`
    echo "Peakachu: $jid"
fi


# mustache
if [ -z $mustache ];
then
    mustache=0
else
jid=`sbatch <<- MUSTACHE | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH -o $debugdir/mustache/debug/$name-%j.log
#SBATCH -e $debugdir/mustache/debug/$name-%j.err
#SBATCH -J "${name}_mustache"
    
date
sh /cluster/home/futing/Project/GBM/HiC/10loop/mustache/mustache_single.sh 10000 $name
#sh /cluster/home/futing/Project/GBM/HiC/10loop/mustache/mustache_single.sh 5000 $name
date
MUSTACHE`
    echo "Mustache: $jid"
fi


# cooltools
if [ -z $cooltools ];then
    cooltools=0
else
jid=`sbatch <<- COOLTOOLS | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH -o $debugdir/cooltools/debug/$name-%j.log
#SBATCH -e $debugdir/cooltools/debug/$name-%j.err
#SBATCH -J "${name}_cooltools"
    
date
sh /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/dots_single.sh 10000 ${name}
# sh /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/dots_single.sh 5000 ${name}

date
COOLTOOLS`

    echo "Cooltools: $jid"
fi

if [ -z $fithic ]
then
    fithic=0
else
    #fithic
jid=`sbatch <<- FITHIC | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH -o $debugdir/fithic/debug/$name-%j.log
#SBATCH -e $debugdir/fithic/debug/$name-%j.err
#SBATCH -J "${name}_fithic"

cd /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts

hicdir=$(find /cluster/home/futing/Project/GBM/HiC/02data/01fastq/ -name ${name} -type d)

# echo -e "\nln -s ${hicdir}/aligned/inter_30.hic /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/${name}.hic\n"
# ln -s ${hicdir}/aligned/inter_30.hic \
#     /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/${name}.hic


echo -e "\n-------------fithic for $name at 10000----------\n"

sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh \
    10000 ${name} "" "" "" ""

echo -e "\n-------------fithic for $name at 5000----------\n"
sh /cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh \
    5000 ${name} "" "" "" ""

FITHIC`
echo "Fithic: $jid"
fi

# homer
if [ -z $homer ];then
    homer=0
else

jid=`sbatch <<- HOMER | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH -o $debugdir/homer/debug/$name-%j.log
#SBATCH -e $debugdir/homer/debug/$name-%j.err
#SBATCH -J "${name}_homer"

cd /cluster/home/futing/Project/GBM/HiC/10loop/homer/scripts

echo -e "\nhomer for $name at 10000\n"
/cluster/home/futing/Project/GBM/HiC/10loop/homer/homer_single.sh \
    10000 ${name} ""

echo -e "\nhomer for $name at 5000\n"
/cluster/home/futing/Project/GBM/HiC/10loop/homer/homer_single.sh \
    5000 ${name} ""

HOMER`
    echo "HOMER: $jid"

fi