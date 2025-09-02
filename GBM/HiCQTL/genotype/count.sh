#!/bin/bash

find ./ -name 'snp.out.vcf' | while read -r file;do
	name=$(dirname $file)
	echo -e "Processing $name...\n"
	num=$(vcftools --vcf "$file" --remove-indels --recode --stdout 2>/dev/null | grep -v '^#' | wc -l)
	echo -e "$name\t$num" >> count.txt
done 