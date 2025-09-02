ls *_* | while read line; do a=${line/.txt/}; dir1=$(echo $a | cut -d_ -f1); dir2=$(echo $a | cut -d_ -f2); sh ~/download/ascp_download_fastq.sh $line $dir1/$dir2 10m ; done > download.log 2>&1 &

ls */*/* | while read line; do parallel-fastq-dump  -s $line -t 6  -O $(dirname $line) --split-files --gzip   -T tmp; done
