#sh /cluster/home/jialu/juicer/misc/calculate_map_resolution.sh /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/dchic/4DNFI5LCW273_100000.matrix iPSC_bp.txt
for i in 4DNFI5LCW273 NPC GBMmerge pGBMmerge
do
	valid_bin=`awk 'BEGIN{PROCINFO["sorted_in"] = "@ind_num_asc"}{fline[$1]+=$3;sline[$2]+=$3}END{for(i in fline)print fline[i]+sline[i]}' ${i}_100000.matrix | awk '$1>1000{valid++}END{print valid}'`
	total_bin=`wc -l  ${i}_100000_abs.bed |cut -d " " -f 1`
	awk -v valid_bin=$valid_bin -v total_bin=$total_bin 'BEGIN{print "'$i'",valid_bin/total_bin}'
done
