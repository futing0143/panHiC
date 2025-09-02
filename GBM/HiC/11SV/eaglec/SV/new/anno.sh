#for i in `cat file.list` 
#do 
#cat ${i}| awk '{print $1"\t"$4"\t"$2"\t"$5}' > ${i%%.*}.GFusion.txt
#annotate-gene-fusion --sv-file ${i%%.*}.GFusion.txt --output-file ${i%%.*}.gene-fusions.txt  --buff-size 10000 --skip-rows 0 --ensembl-release 93 --species human
#done

#for i in `cat Gfusion_file` 
#do 
#cat ${i}| awk '{print $5}' > ${i%%.*}.GFusiononly.txt
#done

#for i in `cat Gfusion_file` 
#do 
#cat ${i}| awk -v T=${i%%.*} '{if($1 == $3) {print $1"\t"$5"\t"T"cis""\t""cis""\t"T}else{print $1"-"$3"\t"$5"\t"T"trans""\t""trans""\t"T}}'  >> GF_collect.txt
#done
#cat GF_collect.txt | awk '{print $3}' |sort|uniq -c >> GF_collect_count.txt
#cat GF_collect.txt | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$5":"$1}' >> GF_collect.txt
#delete first of them
#cat GF_collect.txt | awk '{print $6}' |sort|uniq -c > GF_collect_clvschr.txt

#for i in  GBM GSC NHA_ICE NPC_ICE WTC_ICE pGBM
#do 
#cat ${i}.CNN_SVs.5K_combined.txt | awk '{print $1"\t"$4"\t"$2"\t"$5}' > ${i%%.*}.GFusion.txt
#annotate-gene-fusion --sv-file ${i%%.*}.GFusion.txt --output-file ${i%%.*}.gene-fusions.txt  --buff-size 10000 --skip-rows 0 --ensembl-release 93 --species human

#cat ${i}.CNN_SVs.5K_combined.txt| awk -v T=${i%%.*} '{if($1 == $2) {print $1"\t"$6"\t"T":""cis""\t""cis""\t"T}else{print $1"-"$2"\t"$6"\t"T":""trans""\t""trans""\t"T}}'  >> SV.txt
#done
cat SV.txt | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$5":"$1"\t"$5":"$2}' >> SV_collect.txt
cat SV_collect.txt | awk '{print $3}' |sort|uniq -c >> SV_Cis2Trans.txt
cat SV_collect.txt | awk '{print $6}' |sort|uniq -c >> SV_chr.txt
cat SV_collect.txt | awk '{print $7}' |sort|uniq -c >> SV_type.txt

