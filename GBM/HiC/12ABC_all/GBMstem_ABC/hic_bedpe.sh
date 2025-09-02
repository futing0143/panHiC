#hicConvertFormat -m /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/GBMstem_5000.cool -o GBMstem_5000.ginteractions --inputFormat cool --outputFormat ginteractions
# awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"".""\t"$7}' GBMstem_5000.ginteractions.tsv > GBMstem_5000.ginteractions.bedpe

# cat /cluster/home/futing/Project/GBM/HiC/12ABC_all/GSC4121_ABC/chrname | while read i
# do
# mkdir hic_bedpe/${i}
# sed -n "/${i}/p" GBMstem_5000.ginteractions.bedpe > /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBMstem_ABC/hic_bedpe/${i}/${i}.bedpe
# gzip /cluster/home/futing/Project/GBM/HiC/12ABC_all/GBMstem_ABC/hic_bedpe/${i}/${i}.bedpe
# done
python /cluster/home/futing/software/ABC/src/compute_powerlaw_fit_from_hic.py --hicDir hic_bedpe --outDir hic_bedpe/powerlaw/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all --hic_type bedpe
