#对每个rep样本进行格式转化
cat /cluster/home/futing/Project/GBM/HiC/00data/GBM/ourdata/txt2hic/merge/namelist | while read i
do
hicConvertFormat -m merge_all/${i}/aligned/inter.hic --inputFormat hic --outputFormat cool -o file12_100kcool/${i}.cool --resolutions 100000
hicConvertFormat -m separate/${i}_100000.cool --inputFormat cool --outputFormat h5  -o separate/${i}_100k.h5 --resolutions 100000
#生成Hi-C矩阵的诊断图，这有助于评估数据质量和需要的校正
hicCorrectMatrix diagnostic_plot --matrix file_100kcool/${i}_100k.h5 -o file_100kcool/${i}_100k_diag.png
##矫正h5文件
hicCorrectMatrix correct -m file_100kcool/${i}_100k.h5 --filterThreshold -1.5 5 -o file_100kcool/${i}_100k_corrected.h5
done

#对每个rep样本进行归一化
cd file12_100kcool
hicNormalize -m ts543_kd_rep1_100000.cool ts543_kd_rep2_100000.cool ts543_kd_rep3_100000.cool ts543_ck_rep1_100000.cool ts543_ck_rep2_100000.cool ts543_ck_rep3_100000.cool ts667_kd_rep1_100000.cool ts667_kd_rep2_100000.cool ts667_kd_rep3_100000.cool ts667_ck_rep1_100000.cool ts667_ck_rep2_100000.cool ts667_ck_rep3_100000.cool \
--normalize smallest  \
-o ts543_kd_rep1_100000_normalized.cool ts543_kd_rep2_100000_normalized.cool ts543_kd_rep3_100000_normalized.cool ts543_ck_rep1_100000_normalized.cool ts543_ck_rep2_100000_normalized.cool ts543_ck_rep3_100000_normalized.cool ts667_kd_rep1_100000_normalized.cool ts667_kd_rep2_100000_normalized.cool ts667_kd_rep3_100000_normalized.cool ts667_ck_rep1_100000_normalized.cool ts667_ck_rep2_100000_normalized.cool ts667_ck_rep3_100000_normalized.cool
#绘制每个样本的correlation
hicCorrelate --matrices ts543_kd_rep1_100000_normalized.cool ts543_kd_rep2_100000_normalized.cool ts543_kd_rep3_100000_normalized.cool ts543_ck_rep1_100000_normalized.cool ts543_ck_rep2_100000_normalized.cool ts543_ck_rep3_100000_normalized.cool ts667_kd_rep1_100000_normalized.cool ts667_kd_rep2_100000_normalized.cool ts667_kd_rep3_100000_normalized.cool ts667_ck_rep1_100000_normalized.cool ts667_ck_rep2_100000_normalized.cool ts667_ck_rep3_100000_normalized.cool \
--outFileNameHeatmap hicCorrelate100knorm_heatmap.png \
--outFileNameScatter hicCorrelate100knorm_scatter.png --plotNumbers  \
--labels ts543_kd_rep1 ts543_kd_rep2 ts543_kd_rep3 ts543_ck_rep1 ts543_ck_rep2 ts543_ck_rep3 ts667_kd_rep1 ts667_kd_rep2 ts667_kd_rep3 ts667_ck_rep1 ts667_ck_rep2 ts667_ck_rep3

###对先合并的文件进行归一化
hicNormalize -m ts543_kd_100000.cool ts543_ck_100000.cool ts667_kd_100000.cool ts667_ck_100000.cool \
--normalize smallest \
-o ts543_kd_100000_normalized.cool ts543_ck_100000_normalized.cool ts667_kd_100000_normalized.cool ts667_ck_100000_normalized.cool 

