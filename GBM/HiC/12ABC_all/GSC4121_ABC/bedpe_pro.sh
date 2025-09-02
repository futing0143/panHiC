cat chrname | while read i
do
mkdir hic_bedpe/${i}
sed -n "/${i}/p" /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/hic_bedpe/GSC_5k.ginteractions.bedpe > /cluster/home/jialu/GBM/HiC/GSC4121_ABC/hic_bedpe/${i}/${i}.bedpe
gzip /cluster/home/jialu/GBM/HiC/GSC4121_ABC/hic_bedpe/${i}/${i}.bedpe

done
python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/compute_powerlaw_fit_from_hic.py --hicDir hic_bedpe/ --outDir hic_bedpe/powerlaw/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all --hic_type bedpe
