#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/info/coolerinfo
output=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/info/coolerinfo/coolerinfo.txt
touch $output

cat /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/info/infolist.txt | while read i; do
  sum=$(cooler info /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/${i}_10000.cool | grep -Po '"sum": \K[0-9]+')
  echo -e "$i\t$sum" >> $output
done