#!/bin/bash


total=3088269832

if [ "$#" -ne 2 ]
then
    echo "Usage: calculate_map_resolution.sh <merged_nodups file> <50bp coverage file>"
    echo "  <merged_nodups file>: file created by Juicer containing all valid+unique read pairs"
    echo "  <50bp coverage file>: where to write the 50bp coverage file; if this file is non-empty, the 50bp coverage vector won't be recalculated"
    exit
fi	

filename=$1
coveragename=$2

# chr1    10000   15000   chr4    175000  180000  1

# Create 50bp coverage vector
if [ ! -s "$coveragename" ]
then
    awk '{
      # $7 是接触次数
      count = $9

      if (count>0)
      {
        chr1 = $2
        chr2 = $6

        # 如果两个染色体都存在
        if (chr1 != 0 && chr2 != 0)
        {
          # read1 的位置按 50 bp bin 累加 count
          bin1 = int($3/50)*50
          val[chr1 " " bin1] += count

          # read2 的位置按 50 bp bin 累加 count
          bin2 = int($7/50)*50
          val[chr2 " " bin2] += count
        }
      }
   }
   END {
     for (i in val)
       print i, val[i]
   }' "$filename" > "$coveragename"
fi

# threshold is 80% of total bins
binstotal=$(( $total / 50 ))
threshold=$(( $binstotal * 4 ))
threshold=$(( $threshold / 5 ))

echo -ne "."
newbin=50
bins1000=$(awk '$3>=1000{sum++}END{if (sum == 0) print 0; else print sum}' $coveragename)
lowrange=$newbin

# find reasonable range with big jumps
while [ $bins1000 -lt $threshold ]
do
    lowrange=$newbin
    newbin=$(( $newbin + 1000 ))
    echo -ne "."
    bins1000=$(awk -v x=$newbin '{ 
      val[$1 " " int($2/x)*x]=val[$1 " " int($2/x)*x]+$3
    }
    END { 
      for (i in val) { 
        if (val[i] >= 1000) {
          count++
        } 
     } 
     print count
   }' $coveragename )
    binstotal=$(( $total / $newbin ))
    threshold=$(( $binstotal * 4 ))
    threshold=$(( $threshold / 5 ))
done

# at this point, lowrange failed but newbin succeeded
# thus the map resolution is somewhere between (lowrange, newbin]
midpoint=$(( $newbin - $lowrange ))
midpoint=$(( $midpoint / 2 ))
midpoint=$(( $midpoint + $lowrange ))
# now make sure it's a factor of 50 (ceil)
midpoint=$(( $midpoint + 49 ))
midpoint=$(( $midpoint / 50 ))
midpoint=$(( $midpoint * 50 ))

# binary search
while [ $midpoint -lt $newbin ]
do
    echo -ne "."
    bins1000=$(awk -v x=$midpoint '{ 
      val[$1 " " int($2/x)*x]=val[$1 " " int($2/x)*x]+$3
    }
    END { 
      for (i in val) { 
        if (val[i] >= 1000) {
          count++
        } 
     } 
     print count
   }' $coveragename )
    binstotal=$(( $total / $midpoint ))
    threshold=$(( $binstotal * 4 ))
    threshold=$(( $threshold / 5 ))
    if [ $bins1000 -lt $threshold ]
    then
	lowrange=$midpoint;
	# at this point, lowrange failed but newbin succeeded
	midpoint=$(( $newbin - $lowrange ))
	midpoint=$(( $midpoint / 2 ))
	midpoint=$(( $midpoint + $lowrange ))
	# now make sure it's a factor of 50 (ceil)
	midpoint=$(( $midpoint + 49 ))
	midpoint=$(( $midpoint / 50 ))
	midpoint=$(( $midpoint * 50 ))
    else
	newbin=$midpoint;
	# at this point, lowrange failed but newbin succeeded
	midpoint=$(( $newbin - $lowrange ))
	midpoint=$(( $midpoint / 2 ))
	midpoint=$(( $midpoint + $lowrange ))
	# now make sure it's a factor of 50
	midpoint=$(( $midpoint + 49 ))
	midpoint=$(( $midpoint / 50 ))
	midpoint=$(( $midpoint * 50 ))
    fi
done

echo -e "\nThe map resolution is $newbin"
