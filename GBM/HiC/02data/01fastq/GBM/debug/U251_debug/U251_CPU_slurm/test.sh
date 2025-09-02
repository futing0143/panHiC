#!/bin/bash
outputdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm/aligned
debugdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251_slurm/debug
groupname=test
queue=gpu


awkscript='BEGIN{sscriptname = sprintf("%s/.%s_rmsplit.slurm", debugdir, groupname);}NR==1{if (NF == 2 && $1 == $2 ){print "Sorted and dups/no dups files add up"; printf("#!/bin/bash -l\n#SBATCH -o %s/dup-rm.out\n#SBATCH -e %s/dup-rm.err\n#SBATCH -p %s\n#SBATCH -J %s_msplit0\n#SBATCH -d singleton\n#SBATCH -t 1440\n#SBATCH -c 1\n#SBATCH --ntasks=1\ndate;\nrm %s/*_msplit*_optdups.txt; rm %s/*_msplit*_dups.txt; rm %s/*_msplit*_merged_nodups.txt;rm %s/split*;\ndate\n", debugdir, debugdir, queue, groupname, dir, dir, dir, dir) > sscriptname; sysstring = sprintf("sbatch %s", sscriptname); system(sysstring);close(sscriptname); }else{print "Problem"; print "***! Error! The sorted file and dups/no dups files do not add up, or were empty."}}'
ls -l ${outputdir}/merged_sort.txt | awk '{printf("%s ", $5)}' > $debugdir/dupcheck-${groupname}
ls -l ${outputdir}/merged_nodups.txt ${outputdir}/dups.txt ${outputdir}/opt_dups.txt | awk '{sum = sum + $5}END{print sum}' >> $debugdir/dupcheck-${groupname}
awk -v debugdir=$debugdir -v queue=$queue -v groupname=$groupname -v dir=$outputdir '$awkscript' $debugdir/dupcheck-${groupname}