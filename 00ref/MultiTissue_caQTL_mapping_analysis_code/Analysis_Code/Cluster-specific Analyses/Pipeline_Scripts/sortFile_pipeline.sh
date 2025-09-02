cpmWithPeakInfo=$1
path=$2


{ head -n1 ${path}/$cpmWithPeakInfo; tail -n+2 ${path}/$cpmWithPeakInfo | sort -k2,2 -k3,3n;} > ${path}/$cpmWithPeakInfo.QTLsorted.txt 
