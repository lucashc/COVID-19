source('./scripts/RGG/geodata.R')
library(ggplot2)
library(reshape2)

plotSIRJ <- function(obj, title="SIRJ-plot", S=TRUE, I=TRUE, R=TRUE, J=TRUE) {
  history <- obj$history
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  mhist <- melt(history, id='day', measure.vars = vars)
  names(mhist) <- c('day', 'casetype', 'cases')
  fig <- ggplot(mhist, aes(x=day, y=cases, color=casetype)) + geom_line() + labs(title=title, x='days', y='cases')
  print(fig)
  #fig
}

plotHeatMap <- function(obj, title="Heat map of infections", from=c(2), start_nodes = FALSE) {
  node_data <- obj$node_data
  d1 <- plotHeatMapGeneral(node_data, title, from, start_nodes, obj=obj)
  print(d1)
}

plotHeatMapGeneral<- function(node_data, title="Heat map of infections", from=c(2), start_nodes = FALSE, obj=NULL, special_theme=FALSE) {
  raw_data <- node_data[node_data$status %in% from, c('x', 'y')]
  geo <- geo.getMask()
  geo <- t(apply(geo, 2, rev))
  geo <- geo*0
  jet.colors <- colorRampPalette(c("#3BAB1D", "yellow","orange","red","#7F0000"))
  d1 <- ggplot()
  d1 <- d1 + geom_tile(data=melt(geo), mapping=aes(x=Var1, y=Var2, fill=value))
  d1 <- d1 + geom_bin2d(data=raw_data, aes(x, y), binwidth=10) + scale_fill_gradientn(colors=jet.colors(7), name='density per 10 km²', na.value='#FFFFFF00')
  if (start_nodes) {
    startnode_data = obj$startnode_data
    d1 <- d1 + geom_point(data=startnode_data[startnode_data$status == 1, c('x', 'y')], aes(x,y, alpha=""), color='blue') 
    d1 <- d1 + scale_alpha_manual(values=1) + labs(alpha='initially infected')
  }
  d1 <- d1 + coord_fixed() + labs(title=title) + xlab('km') + ylab('km')
  if (special_theme) {
    library(showtext)
    font_add('lmodern', regular = '/usr/share/fonts/TTF/cmunrm.ttf')
    showtext_auto()
    d1 <- d1 + theme(rect=element_rect(fill="transparent", color="transparent"), 
                     axis.title.x = element_blank(),
                     axis.title.y = element_blank(),
                     plot.background = element_rect(fill="transparent", colour='transparent'),
                     panel.background = element_rect(fill="transparent", colour='transparent'),
                     plot.title = element_text(family="lmodern", colour='white', size = rel(22)),
                     legend.text = element_text(family="lmodern", colour='white', size=rel(8)),
                     legend.title=element_text(family="lmodern", colour='white', size=rel(10))
                     #legend.spacing.y = unit(0.2, 'cm')
                     ) + scale_x_continuous(breaks=NULL) + scale_y_continuous(breaks=NULL)
  }
  return(d1)
}

plotHeatMapFrames <- function(records, from=c(2), prefix='spread', special_theme=FALSE) {
  if (special_theme) {
    font_add('lmodern', regular = '/usr/share/fonts/TTF/cmunrm.ttf')
  }
  filename <- "./history/%s%04d.png"
  plots <- list()
  for (i in 2:length(records)) {
    plots[[i]] <- plotHeatMapGeneral(records[[i]], sprintf("Cumulative infections at day %d", i-1), from, special_theme = special_theme)
  }
  max_count <- max(ggplot_build(plots[[length(plots)]])$data[[2]]$count)
  print(max_count)
  jet.colors <- colorRampPalette(c("#3BAB1D", "yellow","orange","red","#7F0000"))
  for (i in 1:length(records)) {
    pl <- plots[[i]] + scale_fill_gradientn(colors=jet.colors(7), name='density per 10 km²', na.value='#FFFFFF00', limits=c(0, max_count))
    ggsave(sprintf(filename, prefix, i), plot=pl, dpi=600, bg='transparent')
  }
}

plotNodes <- function(node_data, title="Infections", from=1) {
  raw_data <- node_data[node_data$status == from, c('x', 'y', 'status')]
  geo <- geo.getMask()
  geo <- t(apply(geo, 2, rev))
  geo <- geo*0
  status_name <- c('susceptible', 'newly infected', 'infected', 'recovered')[from+1]
  jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
  d1 <- ggplot()
  d1 <- d1 + geom_tile(data=melt(geo), mapping=aes(x=Var1, y=Var2, fill=value), show.legend=FALSE) + scale_fill_gradient(low='grey', high='grey', na.value='#FFFFFF00')
  d1 <- d1 + geom_point(data=raw_data, aes(x, y, color=factor(status))) + scale_color_discrete(name='status', labels=c(status_name))
  d1 <- d1 + coord_fixed() + labs(title=title) + xlab('km') + ylab('km')
  print(d1)
}


plot.graph_diagnostics <- function(diag, ignore_zero_degree = FALSE) {
  edges_per_node <- diag$edges_per_node
  if (ignore_zero_degree){
    edges_per_node <- edges_per_node[which(edges_per_node>0)]
  }
  distances <- diag$distances
  
  par(mfrow = c(1,3))
  
  edges_minus_outliers <- edges_per_node[which(edges_per_node < quantile(edges_per_node, .99))]
  hist(edges_minus_outliers, main = 'Node degree', xlab = "degree", breaks = max(edges_minus_outliers))
  boxplot(edges_per_node, main = 'Boxplot of node degrees')
  hist(distances, main = 'Distances between connected nodes', xlab = "distance (km)")
}





plot.diagnostic_history <- function(obj) {
  par(mfrow=c(1,2))
  x <- 0:(length(obj)-1)
  avg_degree <- vector()
  avg_dist <- vector()
  for (i in 1:length(obj)) {
    avg_degree[i] <- obj[[i]]$average_degree
    avg_dist[i] <- obj[[i]]$average_distance
  }
  plot(x, avg_degree, type='l', main='Average degree of nodes', xlab='days', ylab='degree')
  plot(x, avg_dist, type='l', main='Average distance', xlab='days', ylab='distance (km)')
}