filename = list.files()

genename = data$Hugo_Symbol
res = data.frame(table(genename))
colnames(res) = c("genename","tmp")

for (i in filename) {
  data = read.csv(i,header = T,sep = "\t")
  genename = data$Hugo_Symbol
  res1 = data.frame(table(genename))
  colnames(res1) = c("genename",i)
  res = merge(res,res1,by="genename",sort = T,all = T)
}

res = res[,-2]

write.csv(res,"wes.MutatedSiteCount.csv",quote = F)
