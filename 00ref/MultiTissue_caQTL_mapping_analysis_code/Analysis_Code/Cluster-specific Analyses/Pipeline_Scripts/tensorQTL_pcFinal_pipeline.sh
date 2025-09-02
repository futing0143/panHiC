i=$1
j=$2

bsub -q voltron_normal -e ${path}/JobOutfiles/cluster${i}.pc${j}.tensorqtl.allChr.err.txt -o ${path}/JobOutfiles/cluster${i}.pc${j}.tensorqtl.allChr.out.txt -M 20000 -R "rusage[mem=20000]" "/path/to/tensorqtl --mode cis --covariates ${path}/prinComp_${j}/cluster${i}.pca${j}.covs.tensorQTL.txt --permutations 1000 --window 10000 ${path}/genotype/cluster${i}_maf_0.05_plink ${path}/cluster${i}_CPM_average_noBL.withPeakInfo.txt.QTLsorted.txt.BW.norm.txt.bed.gz ${path}/prinComp_${j}/tensorqtl_cluster${i}_prinComp${j}_allChr_4.3.24 --seed 123"

