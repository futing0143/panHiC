#conda activate neoloop
file=`basename $1`
filename=${file%%.*}
enzeme=$2
outputdir=$3
calculate-cnv -H $1::resolutions/50000 -g hg38  -e ${enzeme} --output ${outputdir}/${filename}_50000.CNV-profile.bedGraph
#segment-cnv --cnv-file ${outputdir}/${filename}_100000.CNV-profile.bedGraph --binsize 100000  --ploidy 2 --output ${outputdir}/${filename}_100000.CNV-seg.bedGraph --nproc 4
#plot-cnv --cnv-profile ${outputdir}/${filename}_100000.CNV-profile.bedGraph  --cnv-segment ${outputdir}/${filename}_100000.CNV-seg.bedGraph --output-figure-name ${outputdir}/${filename}_100000.CNV.genome-wide.png --dot-size 0.5 --dot-alpha 0.2 --line-width 1 --boundary-width 0.5 --label-size 7 --tick-label-size 6 --clean-mode            
#correct-cnv -H $1::resolutions/100000  --cnv-file ${outputdir}/${filename}_100000.CNV-seg.bedGraph --nproc 4 -f



#sh cnv_circ.sh /cluster/home/jialu/GBM/HiC/otherGBM/GSM4417601_A172_b38d5.mcool MboI A172
#for reso in 50000 10000 5000
cat filename_merge | while read name
do 
mkdir uniform/${name}
for reso in 50000 
do
calculate-cnv -H /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${reso}/${name}_${reso}.cool -g hg38  -e uniform --output uniform/${name}/${name}_${reso}.CNV-profile.bedGraph
segment-cnv --cnv-file uniform/${name}/${name}_${reso}.CNV-profile.bedGraph --binsize ${reso}  --ploidy 2 --output uniform/${name}/${name}_${reso}.CNV-seg.bedGraph --nproc 4
plot-cnv --cnv-profile uniform/${name}/${name}_${reso}.CNV-profile.bedGraph  --cnv-segment uniform/${name}/${name}_${reso}.CNV-seg.bedGraph --output-figure-name uniform/${name}/${name}_${reso}.CNV.genome-wide.png --dot-size 0.5 --dot-alpha 0.2 --line-width 1 --boundary-width 0.5 --label-size 7 --tick-label-size 6 --clean-mode            
correct-cnv -H /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${reso}/${name}_${reso}.cool  --cnv-file uniform/${name}/${name}_${reso}.CNV-seg.bedGraph --nproc 4 -f

done
done

