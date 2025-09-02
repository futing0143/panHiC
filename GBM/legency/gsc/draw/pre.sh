awk 'NR==1 {for (i=1; i<=NF; i++) printf "%s\tGSC\tuntreated\n", $i; nextfile}' gene-TPM-untreated84.txt > untreated_meta.txt
