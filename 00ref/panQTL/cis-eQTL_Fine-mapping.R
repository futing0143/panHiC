

#######################

# R code for perform cis-eQTL finemapping in TCGA

# Follow a previous study for reference: 
# https://github.com/eQTL-Catalogue/qtlmap/blob/master/bin/run_susie.R

#######################



library(dplyr)
library(data.table)
library(susieR)
library(Matrix)
library(ggplot2)
library(grid)
library(Rfast)

args <- commandArgs(trailingOnly = T)
#args=c("OV")


### file names #############################
info_file=paste0("geno/",args[1],".QC.info.xls")
cis_file=paste0("PancanQTLv1/cis_eQTLs_all_re")

genotype_file=paste0("geno/",args[1],".geno")
covariates_file=paste0("exp_cov/",args[1],".cov")
expression_file=paste0("exp_cov",args[1],".exp")


########
cis_susie_dir="cis_output/"
if (!file.exists(cis_susie_dir)) {dir.create(cis_susie_dir)}

#files
fig_folder <- "figure"
if (!file.exists(fig_folder)) {
  dir.create(fig_folder)
}
fig_folder <- "figure/Finemapping/"
if (!file.exists(fig_folder)) {
  dir.create(fig_folder)
}


###read file############

#genotype
genotype=fread(genotype_file,head = T,sep="\t")
rownames(genotype)=genotype$ID
colnames(genotype)[1]="ID"

#expression
expression_all=fread(expression_file,sep="\t",head=T,check.names =T)
rownames(expression_all)=expression_all$gene
colnames(expression_all)[1]="ID"

#covariates
importQtlmapCovariates <- function(covariates_path){
  pc_matrix = read.table(covariates_path, check.names = F, header = T, stringsAsFactors = F)
  pc_transpose = t(pc_matrix[,-1])
  colnames(pc_transpose) = pc_matrix$cov
  pc_df = dplyr::mutate(as.data.frame(pc_transpose), genotype_id = rownames(pc_transpose)) %>%
    dplyr::as_tibble() %>% 
    dplyr::select(genotype_id, dplyr::everything())
  #Make PCA matrix
  pc_matrix = as.matrix(dplyr::select(pc_df,-genotype_id))
  rownames(pc_matrix) = pc_df$genotype_id
  return(pc_matrix)
}
covariates_matrix = importQtlmapCovariates(covariates_file)
#rm the sample with NA data
exclude_cov = apply(covariates_matrix, 2, sd,na.rm=TRUE) != 0 
exclude_cov[is.na(exclude_cov)]=FALSE # sometimes exclude_cov is NA
covariates_matrix = covariates_matrix[,exclude_cov]
covariates_matrix=na.omit(covariates_matrix)

#tss
tss=fread("exp_cov/TCGA_gene_position.txt",head=T)
colnames(tss)=c("gene","chr","pos","pos2")
tss$chr=as.numeric(tss$chr)
tss$pos=as.numeric(tss$pos)

#info file
info=fread(info_file,head = T,sep="\t") 
colnames(info)[1]="rs"


## finemapping function #######################################################################################
remove.covariate.effects <- function (X, Z, y) {
  # Here I compute two quantities that are used here to remove linear
  # effects of the covariates (Z) on X and y, and later on to
  # efficiently compute estimates of the regression coefficients for
  # the covariates.
  # Add intercept.
  n <- nrow(X)
  
  if (is.null(Z)){Z <- matrix(1,n,1)}
  else{Z <- cbind(1,Z)}
  A   <- forceSymmetric(crossprod(Z))
  #SZy <- as.vector(solve(A,c(y %*% Z)))
  SZy <- as.matrix(solve(A,t(Z) %*% y))
  SZX <- as.matrix(solve(A,t(Z) %*% X))
  if (ncol(Z) == 1) {
    X <- scale(X,center = TRUE,scale = FALSE)
    #y <- y - mean(y)
    y <- scale(y,center = TRUE,scale = FALSE)
  } else {
    
    # The equivalent expressions in MATLAB are  
    #
    #   y = y - Z*((Z'*Z)\(Z'*y))
    #   X = X - Z*((Z'*Z)\(Z'*X))  
    #
    # This should give the same result as centering the columns of X
    # and subtracting the mean from y when we have only one
    # covariate, the intercept.
    #y <- y - c(Z %*% SZy)
    y <- y - Z %*% SZy
    X <- X - Z %*% SZX
  }
  
  return(list(X = X,y = y,SZy = SZy,SZX = SZX))
}
extractResults <- function(susie_object){
  credible_sets = susie_object$sets$cs
  cs_list = list()
  susie_object$sets$purity = dplyr::as_tibble(susie_object$sets$purity) %>%
    dplyr::mutate(
      cs_id = rownames(susie_object$sets$purity),
      cs_size = NA,
      cs_log10bf = NA,
      overlapped = NA
    )
  added_variants = c()
  for (index in seq_along(credible_sets)){
    cs_variants = credible_sets[[index]]
    cs_id = susie_object$sets$cs_index[[index]]
    
    is_overlapped = any(cs_variants %in% added_variants)
    susie_object$sets$purity$overlapped[index] = is_overlapped
    susie_object$sets$purity$cs_size[index] = length(cs_variants)
    susie_object$sets$purity$cs_log10bf[index] = log10(exp(susie_object$lbf[cs_id]))
    if (!is_overlapped) {
      cs_list[[index]] = dplyr::tibble(cs_id = paste0("L", cs_id),
                                       variant_id = susie_object$variant_id[cs_variants])
      added_variants = append(added_variants, cs_variants)
    }
  }
  df = purrr::map_df(cs_list, identity)
  
  #Extract purity values for all sets
  purity_res = susie_object$sets$purity
  
  #Sometimes all the PIP values are 0 and there are no purity values, then skip this step
  if(nrow(purity_res) > 0){
    purity_df = dplyr::as_tibble(purity_res) %>%
      dplyr::filter(!overlapped) %>%
      dplyr::mutate(
        cs_avg_r2 = mean.abs.corr^2,
        cs_min_r2 = min.abs.corr^2,
        low_purity = min.abs.corr < 0.5
      )  %>%
      dplyr::select(cs_id, cs_log10bf, cs_avg_r2, cs_min_r2, cs_size, low_purity) 
  } else{
    purity_df = dplyr::tibble()
  }
  
  #Extract betas and standard errors and lbf_variables
  mean_vec = susieR::susie_get_posterior_mean(susie_object)
  sd_vec = susieR::susie_get_posterior_sd(susie_object)
  names(mean_vec)=susie_object$variant_id
  names(sd_vec)=susie_object$variant_id
  
  alpha_mat = t(susie_object$alpha)
  colnames(alpha_mat) = paste0("alpha", seq(ncol(alpha_mat)))
  mean_mat = t(susie_object$alpha * susie_object$mu) / susie_object$X_column_scale_factors
  colnames(mean_mat) = paste0("mean", seq(ncol(mean_mat)))
  sd_mat = sqrt(t(susie_object$alpha * susie_object$mu2 - (susie_object$alpha * susie_object$mu)^2)) / (susie_object$X_column_scale_factors)
  colnames(sd_mat) = paste0("sd", seq(ncol(sd_mat)))
  lbf_variable_mat = t(susie_object$lbf_variable)
  colnames(lbf_variable_mat) = paste0("lbf_variable", seq(ncol(lbf_variable_mat)))
  posterior_df = dplyr::tibble(variant_id = names(mean_vec), 
                               pip = susie_object$pip,
                               z = susie_object$z,
                               posterior_mean = mean_vec, 
                               posterior_sd = sd_vec) %>%
    dplyr::bind_cols(purrr::map(list(alpha_mat, mean_mat, sd_mat, lbf_variable_mat), dplyr::as_tibble))
  
  if(nrow(df) > 0 & nrow(purity_df) > 0){
    cs_df = purity_df
    variant_df = dplyr::left_join(posterior_df, df, by = "variant_id") %>%
      dplyr::left_join(cs_df, by = "cs_id")
  } else{
    cs_df = NULL
    variant_df = NULL
  }
  
  
  return(list(cs_df = cs_df, variant_df = variant_df))
}
rename_cs_id <- function(cs_id_column) {
  non_na_elements <- cs_id_column[!is.na(cs_id_column)]
  unique_elements <- unique(non_na_elements)
  num_elements <- length(unique_elements)
  new_names <- paste0("L", 1:num_elements)
  
  renamed_column <- ifelse(is.na(cs_id_column), NA, new_names[match(cs_id_column, unique_elements)])
  
  return(renamed_column)
}
draw=function(df_draw){
  # Get unique non-"L0" groups
  unknown_groups <- unique(df_draw$cs_id[df_draw$cs_id != "L0"])
  # Generate color
  blue_to_rainbow <- colorRampPalette(colors = c("blue", "red"))
  # Generate a vector of different colors for the unknown groups
  colors <- setNames(blue_to_rainbow(length(unknown_groups)), unknown_groups)
  
  # Add "L0" with gray color to the vector
  colors["L0"] <- "gray40"
  df_draw$pos=as.numeric(df_draw$pos)
  # Use ggplot to create the scatter plot
  ggplot(df_draw, aes(x = pos, y = pip, color = cs_id)) +
    geom_point(size = 2, alpha = 0.9) + theme_classic(base_size = 18) +
    scale_color_manual(values = colors, breaks = unknown_groups) +
    theme(plot.title = element_text(hjust = 0.5),
          legend.title = element_text(hjust = 0.5)) +
    scale_x_continuous(labels = scales::comma_format()) +
    labs(x = paste0("Chr",df_draw$chr[1]), y = "PIP", 
         title = paste0("Fine-mapping of ",df_draw$gene[1]," in ",df_draw$cancer[1]),
         color = "Credible Set") 
}

##finemapping## 
cis_run_finemapping=function(i){

  print(paste0("running finemapping for ",i," in ",args[1]))
  
#get SNPs in cis-region
  tss_g=subset(tss,gene==i)[1,]
  var_meta=subset(info,chr==tss_g$chr &
                    pos >= tss_g$pos-1000000 &
                    pos <= tss_g$pos+1000000 )
  var_meta=arrange(var_meta,pos)
  if(nrow(var_meta)<=1){return()}
  
  #genotype#
  gt=genotype[match(var_meta$Ori_SNP,genotype$ID),]
  gt_matrix=as.matrix(gt[,-1])
  rownames(gt_matrix)=gt$ID
  class(gt_matrix)<- "numeric"
  #Exclude variants with no alternative alleles
  gt_matrix = gt_matrix[rowSums(round(gt_matrix,0), na.rm = TRUE) != 0,]
  #Replace missing values with row means
  gt_matrix = t(gt_matrix) %>% zoo::na.aggregate()  %>% t()

  if(nrow(gt_matrix) < 2){return()}
  
  #expression#
  gene_vector=subset(expression_all,ID==i)[,-1]
  class(gene_vector) <- "numeric"
  if(length(na.omit(gene_vector))< 1){return()}
  
  #overlap samples
  ov_sample=intersect(row.names(covariates_matrix),intersect(colnames(gt_matrix),names(gene_vector)))
  if (length(ov_sample)==0){
    message("There is no overlap between genotype, expression and covariates")
    return()
  }
  gt_matrix=t(gt_matrix[,ov_sample])
  gene_vector=gene_vector[ov_sample]
  covariates_matrix2=covariates_matrix[ov_sample,]

  if(ncol(covariates_matrix) < 1){return()}

  #run susie
  out = remove.covariate.effects(gt_matrix, covariates_matrix2, gene_vector)
  
  fitted_adjusted = susie(out$X, out$y,L=10,estimate_residual_variance=TRUE,coverage =0.9)

  fitted_adjusted$variant_id = colnames(gt_matrix)
  e=extractResults(fitted_adjusted)
  variant_df=as.data.frame(c())
  cs_df=as.data.frame(c())
  variant_df=as.data.frame(e$variant_df)
  cs_df=as.data.frame(e$cs_df)
  cs_df$cs_id=rename_cs_id(cs_df$cs_id)
  variant_df$cs_id=rename_cs_id(variant_df$cs_id)
  
  if (nrow(variant_df) == 0 && nrow(cs_df) == 0 ) {
    print("There are no credible sets. Write empty matrices and stop execution.")
    return()
  }else{
   
    variant_df$cancer_type=args[1]
    snpinfo=subset(info,Ori_SNP %in% var_meta$Ori_SNP)
    snpinfo$gene=i

    in_cs_variant_df=
      dplyr::filter(variant_df, !is.na(cs_id) & !low_purity)%>%
      dplyr::mutate(cs_index = cs_id) %>%
      dplyr::mutate(Ori_SNP = variant_id) %>%
      dplyr::left_join(snpinfo,in_cs_variant_df,by="Ori_SNP") %>%
      dplyr::mutate(Gene_name=gene) %>%
      dplyr::mutate(cs_id = paste(cancer_type,Gene_name,"cis", cs_index, sep = "_")) %>%
      dplyr::mutate(Variant=paste(chr,pos,Alt_A,Alt_B, sep = "_"))  %>%
      dplyr::mutate(SNP = Ori_SNP) %>%
      dplyr::transmute(Cancer_type=cancer_type,
                       Gene_name, 
                       Variant,
                       RS_id=rs,
                       Chr=chr,Position=pos,
                       Credible_Set=cs_id,Credible_Set_Size=cs_size,PIP=pip,
      )
    
    in_cs_variant_df$Plot=paste0(fig_folder,in_cs_variant_df$Cancer_type[1],
                                 "_",in_cs_variant_df$Gene_name[1],".png")
   
    
 #######################################################################   
    df_draw <- variant_df %>%
      mutate(Ori_SNP = variant_id) %>%
      left_join(snpinfo, by = "Ori_SNP") %>%
      arrange(cs_id) 
    df_draw$cancer=args[1]
    df_draw$cs_id[!is.na(df_draw$cs_id)] <- paste(df_draw$cancer[1], df_draw$gene[1], "cis", df_draw$cs_id[!is.na(df_draw$cs_id)], sep = "_")
    df_draw$cs_id[is.na(df_draw$cs_id)] <- "L0"
    p=draw(df_draw)
    png(in_cs_variant_df$Plot[1], width =3000, height = 1800, res = 300 )
    print(p)
    dev.off()
    ########################################################################   
      
    return(list(output=in_cs_variant_df,
                data=df_draw)
           )
  }
}


#################
eQTL=fread(cis_file,sep="\t",head=T)
eQTL=subset(eQTL,cancer_type==args[1])
eQTL$chr=gsub("chr","",eQTL$chr)
eQTL$chr=as.numeric(eQTL$chr)
colnames(eQTL)[4]="pos"

eQTL_info=inner_join(eQTL,info,by=c("rs","pos","chr"))

egene=as.array(unique(eQTL$gene))

###perform finemapping ###################################################################
result=lapply(egene,cis_run_finemapping)
result=result[!sapply(result,is.null)]

## output the result  #############
cat<- do.call(rbind, lapply(result, function(x) x$output))

cat=select(cat,
           Cancer_type,
           Gene_name,
           RS_id,
           Variant,
           Chr,
           Position,
           Credible_Set,
           Credible_Set_Size,
           PIP
)

######## output ############################
print("Writting the result table.")
cis_susie_output=paste0(cis_susie_dir,args[1],".cis.susie.txt")
fwrite(cat,cis_susie_output,sep="\t",row.names=F,col.names = T,quote = F,na = "NA")

########################################
print("Analysis is done!")
