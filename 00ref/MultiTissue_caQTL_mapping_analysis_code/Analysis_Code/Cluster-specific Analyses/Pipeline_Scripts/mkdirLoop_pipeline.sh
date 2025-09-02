for i in $(seq $prCompStart $prCompEnd); do

#make necessary directories
if [[ -d "${path}/prinComp_${i}" ]]
then
    echo "${path}/prinComp_${i} exists on your filesystem."
else
    mkdir ${path}/prinComp_${i}
fi
done
