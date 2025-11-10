awk '
 /^[A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} / {cancer=$0; next}       # 匹配日期行，暂时存起来
 /^[^\t]+\t[^\t]+\t[^\t]+$/ {split($0,a,"\t"); g1=a[1]; g2=a[2]; g3=a[3]; next}  # cancer,gse,cell
 /The map resolution is/ {match($0,/[0-9]+/,m); res=m[0]; print g1 "\t" g2 "\t" g3 "\t" res}
 ' /cluster2/home/futing/Project/panCancer/check/debug/calres-16551.log \
> /cluster2/home/futing/Project/panCancer/check/res1106.txt


/cluster2/home/futing/Project/panCancer/check/debug/calres-16551.log