#for i in GBM_common GBMstem  ipsc NPC GBMmerge pHGG
# cat /cluster/home/futing/Project/GBM/HiC/10loop/mustache/filename | while read i; do
#   echo "Processing file: $i"
#   cooler info /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/${i}_5000.cool
# done

cat /cluster/home/futing/Project/GBM/HiC/10loop/mustache/filename | while read i; do
  sum=$(cooler info /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/${i}_5000.cool | grep -Po '"sum": \K[0-9]+')
  echo -e "$i\t$sum"
done

