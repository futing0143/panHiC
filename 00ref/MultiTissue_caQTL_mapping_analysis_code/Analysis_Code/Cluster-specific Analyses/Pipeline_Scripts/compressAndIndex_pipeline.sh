if [[ -f "${path}/${cpm}.bed.gz" ]]
then
    echo "${path}/${cpm}.bed.gz exists on your filesystem."
else
    bgzip ${path}/${cpm}.bed
fi


if [[ -f "${path}/${cpm}.bed.gz.tbi" ]]
then
    echo "${path}/${cpm}.bed.gz.tbi exists on your filesystem."
else
tabix ${path}/${cpm}.bed.gz
fi
