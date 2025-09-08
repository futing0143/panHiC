#check for compressed bed file. if it doesn’t exist, compress bed file.
if [[ -f "${cpm}.bed.gz" ]]
then
    echo "${cpm}.bed.gz exists on your filesystem."
else
    bgzip ${cpm}.bed
fi

#check for index file. if it doesn’t exist, create it.
if [[ -f "${cpm}.bed.gz.tbi" ]]
then
    echo "${cpm}.bed.gz.tbi exists on your filesystem."
else
tabix ${cpm}.bed.gz
fi
