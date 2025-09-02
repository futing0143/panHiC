for i in GBMmerge pGBMmerge NPC 4DNFI5LCW273
do
    hicConvertFormat -m 5000/${i}_5000.cool -o ${i}_5k.ginteractions --inputFormat cool --outputFormat ginteractions
    awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"".""\t"$7}' ${i}_5k.ginteractions.tsv > hic_bedpe/${i}_5k.ginteractions.bedpe
    rm ${i}_5k.ginteractions.tsv
done

#------------------被注释掉的代码------------------
cd 5k
cooler merge GB176_5k.cool GB180_5k.cool GB182_5k.cool GB183_5k.cool GB238_5k.cool GSM4417601_A172_b38d5_5k.cool GSM4417602_SW1088_b38d5_5k.cool GSM4417603_U118-MG_b38d5_5k.cool GSM4417604_U87-MG_b38d5_5k.cool GSM4417627_U343_b38d5_5k.cool mergeall_5k.cool
cooler balance GB176_5k.cool
hicConvertFormat -m GB176_5k.cool -o GBM_5k.ginteractions --inputFormat cool --outputFormat ginteractions
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"".""\t"$7}' GBM_5k.ginteractions.tsv > GBM_5k.ginteractions.bedpe
