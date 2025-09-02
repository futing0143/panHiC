awk 'BEGIN { OFS = "\t" } { $2 = $2 - 500; $3 = $3 + 500; print }' /cluster/home/tmp/GBM/HiC/06compartment/cgc/G_CGC_tss.bed > /cluster/home/tmp/GBM/HiC/06compartment/cgc/G_CGC_tss_500ud.bed
