for i in A172_5000.cool   GB182_5000.cool  G583_5000.cool  U118_5000.cool G523_5000.cool   GB183_5000.cool   SW1088_5000.cool    ts667_5000.cool     U343_5000.cool GB176_5000.cool  GB238_5000.cool    ts543_5000.cool     U87_5000.cool GB180_5000.cool  G567_5000.cool
for i in ./norm/A172_normalized.cool ./norm/GB182_normalized.cool ./norm/G583_normalized.cool ./norm/U118_normalized.cool ./norm/G523_normalized.cool ./norm/GB183_normalized.cool ./norm/SW1088_normalized.cool ./norm/ts667_normalized.cool ./norm/U343_normalized.cool ./norm/GB176_normalized.cool ./norm/GB238_normalized.cool ./norm/ts543_normalized.cool ./norm/U87_normalized.cool ./norm/GB180_normalized.cool ./norm/G567_normalized.cool
do 
    echo "Processing: $i"
    hicNormalize -m $i --normalize norm_range -o 0_1norm/${i%.*}_0_1_range.cool
    hicInfo -m 0_1norm/${i%.*}_0_1_range.cool
    cooler balance 0_1norm/${i%.*}_0_1_range.cool
    hicInfo -m 0_1norm/${i%.*}_0_1_range.cool
done


hicNormalize -m A172_5000.cool GB182_5000.cool G583_5000.cool U118_5000.cool G523_5000.cool GB183_5000.cool SW1088_5000.cool ts667_5000.cool U343_5000.cool GB176_5000.cool GB238_5000.cool ts543_5000.cool U87_5000.cool GB180_5000.cool G567_5000.cool --normalize smallest -o ./norm/A172_normalized.cool ./norm/GB182_normalized.cool ./norm/G583_normalized.cool ./norm/U118_normalized.cool ./norm/G523_normalized.cool ./norm/GB183_normalized.cool ./norm/SW1088_normalized.cool ./norm/ts667_normalized.cool ./norm/U343_normalized.cool ./norm/GB176_normalized.cool ./norm/GB238_normalized.cool ./norm/ts543_normalized.cool ./norm/U87_normalized.cool ./norm/GB180_normalized.cool ./norm/G567_normalized.cool
hicConvertFormat --m /cluster/home/tmp/GBM/HiC/02data/03cool/1000000/U87_1000000.cool  --outFileName U87_1000000_raw --inputFormat cool --outputFormat ginteractions --load_raw_values
hicConvertFormat --m /cluster/home/tmp/GBM/HiC/02data/03cool/1000000/ts543_1000000.cool  --outFileName ts543_1000000_raw --inputFormat cool --outputFormat ginteractions --load_raw_values
