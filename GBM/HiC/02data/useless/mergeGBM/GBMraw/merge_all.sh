/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/mega.sh \
        -s /cluster/home/jialu/GBM/hicnew/hg38_GBM.txt \
        -g hg38 \
        -d /cluster/home/jialu/GBM/hicnew/GBMraw \
        -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer 
#        -s '(GATCGATC|AAGCTAGCTT)' 
#        -g /cluster/home/jialu/genome/hg38_24chrm.chrom.size 

#        
#        


#awk '{print $15"\t"$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$12}' \
#        /cluster/home/jialu/GBM/HiC/juicer/ts667/mega/aligned/merged_nodups.txt \
#        |gzip -9 > \
#        /cluster/home/jialu/GBM/HiC/juicer/ts667/mega/aligned/merged_nodups_medium.txt.gz
#    rm -rf /cluster/home/jialu/GBM/HiC/juicer/ts667/mega/aligned/merged_nodups.txt

#$bdir/extra/juicer/scripts/common/juicer_tools apa \
#        -r 25000,10000,5000 \
#        $bname/mega/aligned/inter_30.hic \
#        $bname/mega/aligned/inter_30_loops/merged_loops.bedpe \
#        $bname/mega/aligned/inter_30_apa_results

    # motif search
#    $bdir/extra/juicer/scripts/common/juicer_tools motifs \
#        ${genome} \
#        $bdir/extra/juicer/references/motif \
#        $bname/mega/aligned/inter_30_loops/merged_loops.bedpe 
#/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools pre -s /cluster/home/jialu/GBM/hicnew/GBMraw/mega/aligned/inter_30.txt -g /cluster/home/jialu/GBM/hicnew/GBMraw/mega/aligned/inter_30_hists.m -q 30 /cluster/home/jialu/GBM/hicnew/GBMraw/mega/aligned/merged_nodups.txt /cluster/home/jialu/GBM/hicnew/GBMraw/mega/aligned/inter_30.hic /cluster/home/jialu/genome/hg38_24chrm.chrom.size

             