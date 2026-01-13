#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/anno_loops
echo -e "cancer\tgse\tcell\tenzyme\tcategory\tn\ttotal\tprop" > panCancer_loop_sample_prop_down5w.tsv

metadata="/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt"
output_dir="/cluster2/home/futing/Project/panCancer"
>panCancer_loop_sample_prop.tsv
IFS=$'\t'
while read cancer gse cell enzyme; do
  f="${output_dir}/${cancer}/${gse}/${cell}/anno/mustache/${cell}_loop_category_down5w.tsv"
  [[ ! -f $f ]] && continue

  total=$(awk 'NR>1{c++}END{print c}' $f)

  awk -v cancer=$cancer -v gse=$gse -v cell=$cell -v enzyme=$enzyme -v total=$total '
    NR>1 {cnt[$2]++}
    END {
      for (c in cnt)
        printf "%s\t%s\t%s\t%s\t%s\t%d\t%d\t%.6f\n",
          cancer,gse,cell,enzyme,c,cnt[c],total,cnt[c]/total
    }' $f >> panCancer_loop_sample_prop_down5w.tsv
done < ${metadata}
