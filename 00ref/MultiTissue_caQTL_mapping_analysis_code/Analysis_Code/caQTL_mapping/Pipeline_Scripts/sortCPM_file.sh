{ head -n1 $cpmWithPeakInfo; tail -n+2 $cpmWithPeakInfo | sort -k2,2 -k3,3n;} > $cpmWithPeakInfo.QTLsorted.txt 
