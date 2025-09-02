
cat filename  | while read i;do
    name=$(echo ${i} | awk '{print $1}')
    depth=$(echo ${i} | awk '{print $2}')
    peakachu depth -p "/cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/${name}_5000.cool" 
    peakachu score_genome -r 5000 --balance -p /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/${name}_5000.cool \
        -O ${name}-peakachu-5kb-scores.bedpe -m high-confidence.${depth}.5kb.w6.pkl
    peakachu pool -r 5000 -i ${name}-peakachu-5kb-scores.bedpe -o ${name}-peakachu-5kb-loops.0.95.bedpe -t 0.95
    awk -v T=${name} '{print $1"\t"$2"\t"$6"\t"T"\t"$8}' ${name}-peakachu-5kb-loops.0.95.bedpe > ${name}_loop.bed
    cat ${name}-peakachu-5kb-loops.0.95.bedpe|awk -v T=${name} '{print T"\t"$1"\t"($5+$6-$2-$3)/2}' >> merge_loop_size.txt
done
wget http://3dgenome.fsm.northwestern.edu/peakachu/high-confidence.550million.5kb.w6.pkl
wget http://3dgenome.fsm.northwestern.edu/peakachu/high-confidence.1.8billion.5kb.w6.pkl

peakachu depth -p "/cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/GBM_common_5000.cool" 