#!/bin/bash

d=$1
check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}

unalign=/cluster2/home/futing/Project/panCancer/check/aligned/unalign${d}.txt
unrun_file=/cluster2/home/futing/Project/panCancer/check/aligned/unrun${d}.txt
aligndone=/cluster2/home/futing/Project/panCancer/check/aligned/aligndone${d}.txt
filelist=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
>${unalign}
>${unrun_file}
>${aligndone}
# IFS=$','
# while read -r gse cell other;do
# 	hic_exist=false
# 	f="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/aligned/inter_30.hic"
# 	[ -e "$f" ] && check_file "$f" && hic_exist=true
# 	if ! $hic_exist;then
# 		echo -e "${gse}\t${cell}" >> $unalign
# 	fi
# done < "$filelist"


while IFS=$'\t' read -r cancer gse cell other; do
    splitdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits"
	if ! compgen -G "${splitdir}/*.sam" > /dev/null; then
        echo -e "${cancer}\t${gse}\t${cell}" >> "$unrun_file"
    else
        # 使用进程替换分别处理两类文件
        awk -v cancer="$cancer" -v gse="$gse" -v cell="$cell" \
            -v unalign="$unalign" \
            -v done_file="$aligndone" '
            BEGIN {total=0; check=0}
            {
                # 通过ARGIND判断当前处理的是哪个文件集
                if (ARGIND == 1) { total += $1/4 }
                if (ARGIND == 2) { check += $2 }
            }
            END {
                if (total != check) {
                    print cancer "\t" gse "\t" cell >> unalign
                } else {
                    print cancer "\t" gse "\t" cell >> done_file
                }
            }
        ' <(zcat -f "${splitdir}"/*_linecount.txt*) <(zcat -f "${splitdir}"/*norm*res*.txt*)
    fi
done < "$filelist"



# # 找到正确
: << 'EOF'
i=SRR11187362
# splitdir=/cluster2/home/futing/Project/panCancer/AML/GSE165038/U937/splits
dir=/cluster2/home/futing/Project/panCancer/ALL/GSE145997/ALL_PDX23
cat ${dir}/srr.txt | while read -r srr;do
	splitdir=${dir}/splits
	wctotal=`zcat -f ${splitdir}/${srr}.fastq.gz_linecount.txt.gz | awk '{sum+=$1}END{print sum/4}'`
	check2=`zcat -f ${splitdir}/${srr}.fastq.gz_norm.txt.res.txt.gz | awk '{s2+=$2;}END{print s2}'`
	# echo $wctotal
	# echo $check2
	if [ $wctotal != $check2 ];then
		echo $srr
	fi
done

cat ${dir}/srr.txt | while read -r srr;do
	splitdir=${dir}/splits
	wctotal=`cat ${splitdir}/${srr}.fastq.gz_linecount.txt | awk '{sum+=$1}END{print sum/4}'`
	check2=`cat ${splitdir}/${srr}.fastq.gz_norm.txt.res.txt | awk '{s2+=$2;}END{print s2}'`
	echo $wctotal
	echo $check2
	if [ $wctotal != $check2 ];then
		echo $srr
	fi
done

# wctotal=`zcat ${splitdir}/${i}.fastq.gz_linecount.txt.gz | awk '{sum+=$1}END{print sum/4}'`
# check2=`zcat ${splitdir}/${i}.fastq.gz_norm.txt.res.txt.gz | awk '{s2+=$2;}END{print s2}'`
# echo $wctotal
# echo $check2
EOF
grep -F -w -v -f ./download/err_dir${d}.txt ./aligned/aligndone${d}.txt > ./aligned/realalign${d}.txt
