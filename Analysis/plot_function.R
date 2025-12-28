plot_proportion <- function(df, vectorx = "kmeans", vector2 = "Cancer_Category",
                            colors = NULL, title_text = "Cancer Category") {
  
  # check columns exist
  if (!(vectorx %in% names(df))) stop("vectorx not in df")
  if (!(vector2 %in% names(df))) stop("vector2 not in df")
  
  # 数据准备：统计比例
  dat <- df %>%
    count(.data[[vector2]], .data[[vectorx]]) %>%
    group_by(.data[[vector2]]) %>%
    mutate(
      Total = sum(n),
      Percent = n / Total
    ) %>%
    ungroup()
  
  # 自动颜色：如未提供 colors，则给 5 个默认色
  if (is.null(colors)) {
    colors <- colorRampPalette(c("#D64F38","#F8F2ED","#77A3BB","#16365F"))(length(unique(dat[[vectorx]])))
  }
  
  dat[[vectorx]] <- factor(dat[[vectorx]])
  
  p <- ggplot(dat, aes(x = .data[[vector2]], y = Percent, fill = .data[[vectorx]])) +
    geom_col(position = "stack") +
    scale_fill_manual(values = colors) +
    labs(
      title = title_text,
      x = "",
      y = "Proportion",
      fill = vectorx
    ) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 0.01)) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5, family = "sans"),
      plot.background = element_rect(fill = NA, colour = NA),
      axis.title = element_text(vjust = 0.5, hjust = 0.5, family = "sans", size = 10),
      axis.text.y = element_text(colour = "black", size = 9, family = "sans"),
      axis.text.x = element_text(size = 9, angle = 60, hjust = 1),
      axis.ticks = element_line(colour = "black"),
      axis.line = element_line(colour = "black", linewidth = 0.4),
      panel.border = element_rect(fill = NA, color = NA, linetype = 1),
      panel.grid = element_blank(),
      legend.text = element_text(size = 10, family = "sans"),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
      plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm")
    )
  
  return(p)
}


#------------------------------------------------------------------------
plot_umap_fill <- function(df, fill_col, title_text, colors = "brewer", legendexist = TRUE,xlab="UMAP1",ylab="UMAP2",fill=F) {
  
  # 颜色设置
  if (fill) {
    color_setting <- scale_fill_gradient( low='white',high = "#08519C", name = "Depth")
    fillg <- guide_colorbar()
    
  }else if(identical(colors, "brewer")){
    fillg <- g
    color_setting <- scale_fill_brewer(palette = "Set1")
    
  } 
  else {
    color_setting <- scale_fill_manual(values = colors)
    fillg <- g
  }
  
  p <- ggplot(data = df, aes(x = X1, y = X2, fill = .data[[fill_col]])) +
    geom_point(stroke = 0.35, size = 2, alpha = 0.8, shape = 21, color = "black") +
    color_setting +
    ggtitle(title_text) +
    guides(fill = fillg, size = g, color = g, shape = g) +
    labs(x = xlab, y =ylab) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5, family = "sans"),
      plot.background = element_rect(fill = NA, colour = NA),
      axis.title = element_text(vjust = 0.5, hjust = 0.5, family = "sans", size = 10),
      axis.text = element_text(colour = "black", size = 9, family = "sans"),
      axis.ticks = element_line(colour = "black"),
      axis.line = element_line(colour = "black", linewidth = 0.4),
      panel.border = element_rect(fill = NA, color = NA, linetype = 1),
      panel.grid = element_blank(),
      legend.text = element_text(size = 10, family = "sans"),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.margin = margin(t = 0, r = 1, b = 0, l = 0, unit = "pt"),
      legend.title = element_blank(),
      plot.margin = unit(c(0.5, 0.5, 0, 0.5), "cm")
    )
  
  # legend 控制（动态添加 theme）
  if (!legendexist) {
    p <- p + theme(legend.position = "none")
  }
  
  return(p)
}

#-----------------------------
plot_legend <- function(df, fill_col, title, colors = "brewer", fill = FALSE) {
  
  if (fill) {
    # 连续变量
    color_setting <- scale_fill_gradient(
      low = 'white',
      high = "#08519C",
      name = title
    )
    fillg <- guide_colorbar()
    
  } else if (identical(colors, "brewer")) {
    # 离散变量（brewer）
    color_setting <- scale_fill_brewer(palette = "Set1")
    fillg <- guide_legend(ncol = 1)
    
  } else {
    # 离散变量（手动颜色）
    color_setting <- scale_fill_manual(values = colors)
    fillg <- guide_legend(ncol = 1)
  }
  
  get_legend(
    ggplot(df, aes(x = X1, y = X2, fill = .data[[fill_col]])) +
      geom_point(
        stroke = 0.35, size = 3, alpha = 0.8,
        shape = 21, color = "black"
      ) +
      color_setting +
      labs(fill = title) +
      guides(fill = fillg) +
      theme_bw() +
      theme(
        legend.position = "right",
        legend.text = element_text(size = 10, family = "sans"),
        legend.background = element_rect(fill = NA, colour = NA),
        legend.title = element_blank(),
        legend.margin = margin(0, 0, 0, 0, unit = "pt")
      )
  )
}

