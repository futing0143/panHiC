#for i in 4DNFI5LCW273 NPC GBMmerge pGBMmerge 
#do

#fanc insulation /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/25k/${i}_25k.cool ${i}_25k.insulation 
#fanc insulation ${i}_25k.insulation  -o bed
#fanc boundaries ${i}_25k.insulation ${i}_25k.insulation_boundries -w 1mb 2mb
#fanc directionality /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/25k/${i}_25k.cool ${i}_25k.directionality
#fanc directionality ${i}_25k.directionality -o bed
#done
fanc compare -c difference GBMmerge_25k.directionality pGBMmerge_25k.directionality GBMvspHGG
