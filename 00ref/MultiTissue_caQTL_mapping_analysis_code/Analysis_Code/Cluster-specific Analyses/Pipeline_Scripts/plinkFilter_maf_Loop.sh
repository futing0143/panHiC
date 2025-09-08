for i in {1..11};do

	plink --bfile path/to/plink/cluster${i}/genotype/cluster${i}_plink --maf 0.05 --make-bed --out /path/to/plink/output/cluster${i}/genotype/cluster${i}_maf_0.05_plink
	
done
