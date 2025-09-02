peakachu score_genome -r 5000 --balance -p \
    /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/pHGG_5000.cool \
    -O pHGG-peakachu-5kb-scores.bedpe -m high-confidence.2billion.5kb.w6.pkl
peakachu pool -r 5000 -i pHGG-peakachu-5kb-scores.bedpe -o pHGG-peakachu-5kb-loops.0.95.bedpe -t 0.95
 
# 我的电脑用不了 --balance 参数，所以我改成了--clr-weight-name weight