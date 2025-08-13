##resoANDh.list中每个分辨率的四种type两两间的hicrep值
while read i h 
do
    for k in pGBMmerge NPC GBMmerge 4DNFI5LCW273
    do
        for j in pGBMmerge NPC GBMmerge 4DNFI5LCW273
        do
            if [ "$k" != "$j" ]; then
                hicrep ${i}/GBMmerge_${i}.cool ${i}/${j}_${i}.cool ${i}/GBMmerge_${j%%_*}.txt --h ${h} --dBPMax 5000000
                hicrep ${i}/${k}_${i}.cool ${i}/${j}_${i}.cool ${i}/${k}_${j}.txt --h ${h} --dBPMax 5000000
             fi
        done
    done
done < resoANDh.list

#规定i和h的值
i=50000
h=4
for k in pGBMmerge NPC GBMmerge 4DNFI5LCW273
    do
        for j in pGBMmerge NPC GBMmerge 4DNFI5LCW273
        do
            if [ "$k" != "$j" ]; then
                hicrep ${i}/GBMmerge_${i}.cool ${i}/${j}_${i}.cool ${i}/GBMmerge_${j%%_*}.txt --h ${h} --dBPMax 5000000
                hicrep ${i}/${k}_${i}.cool ${i}/${j}_${i}.cool ${i}/${k}_${j}.txt --h ${h} --dBPMax 5000000
            fi
        done
    done
done
