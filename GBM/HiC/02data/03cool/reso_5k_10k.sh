cd /cluster/home/futing/Project/GBM/HiC/02data/03cool/10000
for i in 4DNFI5LCW273 NPC GBMmerge pGBMmerge 
do
	python /cluster/home/jialu/BioSoft/dcHiC-master/utility/preprocess.py -input cool -file ${i}_10000.cool -genomeFile /cluster/home/jialu/genome/hg38_24chrm.chrom.size -res 10000 -prefix ${i}
	valid_bin=`awk 'BEGIN{PROCINFO["sorted_in"] = "@ind_num_asc"}{fline[$1]+=$3;sline[$2]+=$3}END{for(i in fline)print fline[i]+sline[i]}' ${i}_10000.matrix | awk '$1>1000{valid++}END{print valid}'`
	total_bin=`wc -l  ${i}_10000_abs.bed |cut -d " " -f 1`
	awk -v valid_bin=$valid_bin -v total_bin=$total_bin 'BEGIN{print "'$i'",valid_bin/total_bin}'
done

for i in 4DNFI5LCW273 NPC GBMmerge pGBMmerge 
do
	python /cluster/home/jialu/BioSoft/dcHiC-master/utility/preprocess.py -input cool -file ${i}_5000.cool -genomeFile /cluster/home/jialu/genome/hg38_24chrm.chrom.size -res 5000 -prefix ${i}
	valid_bin=`awk 'BEGIN{PROCINFO["sorted_in"] = "@ind_num_asc"}{fline[$1]+=$3;sline[$2]+=$3}END{for(i in fline)print fline[i]+sline[i]}' ${i}_5000.matrix | awk '$1>1000{valid++}END{print valid}'`
	total_bin=`wc -l  ${i}_5000_abs.bed |cut -d " " -f 1`
	awk -v valid_bin=$valid_bin -v total_bin=$total_bin 'BEGIN{print "'$i'",valid_bin/total_bin}'
done
