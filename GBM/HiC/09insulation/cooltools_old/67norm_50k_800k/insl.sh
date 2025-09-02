for i in /cluster/home/tmp/GBM/HiC/02data/03cool/50000/norm/*.cool; do
    filename=$(basename -- "$i")
    insulation_file="${filename%_50000_normalized.cool}_insul.tsv"
    cooler balance "$i"
    cooltools insulation "$i" -o "${insulation_file}" 800000
done
