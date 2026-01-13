#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/mutation_load/PCAWG
meta=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/brca_tcga_pub2015/data_clinical_patient.txt
name='PCAWG'
wkdir=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/PCAWG

tail -n +5 $meta > BRCA_meta.txt

tail -n +2 /cluster2/home/futing/Project/panCancer/Analysis/mutation_load/BRCA_survival_donor.tsv \
| cut -f1 > BRCA_donor.txt

head -n1 ${wkdir}/October_2016_whitelist_2583.snv_mnv_indel.maf.xena.nonUS > BRCA_mutation.maf


grep -w -F -f ${wkdir}/BRCA_donor.txt \
	${wkdir}/October_2016_whitelist_2583.snv_mnv_indel.maf.xena.nonUS > BRCA_hg19.bed
grep -w -F -f ${wkdir}/BRCA_donor.txt \
	${wkdir}/October_2016_whitelist_2583.snv_mnv_indel.maf.xena.nonUS | awk 'BEGIN{OFS="\t"}{
  print "chr"$2, $3-1, $4, NR
}'  > PCAWG_hg19.bed


liftOver ${name}_hg19.bed /cluster2/home/futing/ref_genome/liftover/hg19ToHg38.over.chain \
    ${name}_hg38.bed ${name}_hg38.unmapped

awk 'BEGIN{OFS="\t"}{
  print $4, $1, $2+1, $3
}' ${name}_hg38.bed > liftover_map.txt


awk '
BEGIN{OFS="\t"}
NR==FNR{
  chr[$1]=$2
  start[$1]=$3
  end[$1]=$4
  next
}
{
  if(chr[FNR]!="")
    print $0, chr[FNR], start[FNR], end[FNR]
}
' liftover_map.txt BRCA_hg19.bed > BRCA_hg38.bed