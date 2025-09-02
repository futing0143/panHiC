#for i in NPC GBMmerge ipsc
#for i in GBM_common GBMstem
# cat filename |while read i
# do
# cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/50000/${i}_50000.cool
# cooltools insulation /cluster/home/futing/Project/GBM/HiC/02data/03cool/50000/${i}_50000.cool -o ${i}_insul.tsv 800000
# done

# while IFS= read -r i || [[ -n "$i" ]]; do
#     cooler balance "/cluster/home/futing/Project/GBM/HiC/02data/03cool/50000/${i}_50000.cool"
#     cooltools insulation "/cluster/home/futing/Project/GBM/HiC/02data/03cool/50000/${i}_50000.cool" -o "${i}_insul.tsv" 800000
# done < "filename1"


paste -d'\t' GBMmerge_insul.tsv NPC_insul.tsv pHGG_insul.tsv ipsc_insul.tsv GBM_common_insul.tsv GBMstem_insul.tsv |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$6,$15,$24,$33,$42,$51}' > IS_GBMmergeNpiDs.txt  
awk 'NR==1{$4="GBMmerge";$5="NPC";$6="pHGG";$7="iPSC";$8="DGC";$9="GSC"}1' IS_GBMmergeNpiDs.txt > IS_GBMmergeNpiDs1.txt
awk '{for(i=4;i<=10;i++){if($i=="nan") $i=0}} 1' IS_GBMmergeNpiDs1.txt >IS_GBMmergeNpiDs2.txt

paste -d'\t' A172_insul.tsv G523_insul.tsv GB176_insul.tsv GB180_insul.tsv GB182_insul.tsv GB183_insul.tsv GB238_insul.tsv GB567_insul.tsv GB583_insul.tsv SW1088_insul.tsv U118_insul.tsv U343_insul.tsv U87_insul.tsv ts543_insul.tsv ts667_insul.tsv |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$6,$15,$24,$33,$42,$51,$60,$69,$78,$87,$96,$105,$114,$123,$132}' > BS_GBMsample.txt 
awk 'NR==1{$4="A172";$5="G523*";$6="GB176";$7="GB180";$8="GB182";$9="GB183";$10="GB238";$11="GB567*";$12="GB583*";$13="SW1088";$14="U118";$15="U343";$16="U87";$17="ts543*";$18="ts667*"}1' BS_GBMsample.txt > BS_GBMsample1.txt
awk '{for(i=4;i<=10;i++){if($i=="nan") $i=0}} 1' BS_GBMsample1.txt >BS_GBMsample2.txt

paste -d'\t' A172_insul.tsv G523_insul.tsv GB176_insul.tsv GB180_insul.tsv GB182_insul.tsv GB183_insul.tsv GB238_insul.tsv GB567_insul.tsv GB583_insul.tsv SW1088_insul.tsv U118_insul.tsv U343_insul.tsv U87_insul.tsv ts543_insul.tsv ts667_insul.tsv |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$8,$17,$26,$35,$44,$53,$62,$71,$80,$89,$98,$107,$116,$125,$134}' > IS_GBMsample.txt 
awk 'NR==1{$4="A172";$5="G523*";$6="GB176";$7="GB180";$8="GB182";$9="GB183";$10="GB238";$11="GB567*";$12="GB583*";$13="SW1088";$14="U118";$15="U343";$16="U87";$17="ts543*";$18="ts667*"}1' IS_GBMsample.txt > IS_GBMsample1.txt
awk '{for(i=4;i<=10;i++){if($i=="nan") $i=0}} 1' IS_GBMsample1.txt >IS_GBMsample2.txt
