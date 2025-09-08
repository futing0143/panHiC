
path=$1
i=$2

plink2 --bfile ${path}/cluster${i}/genotype/cluster${i}_maf_0.05_plink --pca  --out ${path}/cluster${i}/genotype/cluster${i}
