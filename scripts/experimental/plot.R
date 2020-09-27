source('./scripts/experimental/geodata.R')
library(ggplot2)
library(reshape2)

plotSIRJ <- function(obj, title="SIRJ-plot", S=TRUE, I=TRUE, R=TRUE, J=TRUE) {
  history <- obj$history
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  mhist <- melt(history, id='day', measure.vars = vars)
  names(mhist) <- c('day', 'casetype', 'cases')
  fig <- ggplot(mhist, aes(x=day, y=cases, color=casetype)) + geom_line() + labs(title=title, x='days', y='cases')
  print(fig)
  fig
}

plotHeatMap<- function(obj, title="Heat map of infections", from=1) {
  node_data <- obj$node_data
  raw_data <- node_data[node_data$status == 2, c('x', 'y')]
  geo <- geo.getMask()
  geo <- t(apply(geo, 2, rev))
  geo <- geo*0
  jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
  d1 <- ggplot()
  d1 <- d1 + geom_tile(data=melt(geo), mapping=aes(x=Var1, y=Var2, fill=value))
  d1 <- d1 + geom_bin2d(data=raw_data, aes(x, y), binwidth=10) + scale_fill_gradientn(colors=jet.colors(7), name='density per 10 km²')
  d1 <- d1 + coord_fixed() + labs(title=title) + xlab('km') + ylab('km')
  print(d1)
}

plot.graph_diagnostics <- function(diag){
  par(mfrow = c(1,2))
  edges_hist = hist(diag$edges_per_node, plot=FALSE)
  plot(edges_hist, main = 'Edges connected to a node', xlab = "edges connected to node")
  distance_hist = hist(diag$distances, plot=FALSE)
  plot(distance_hist, main = 'Distances between connected nodes', xlab = "distance (km)")
}

plot.diagnostic_history <- function(obj) {
  par(mfrow=c(1,2))
  x <- 0:(length(obj)-1)
  avg_edges <- vector()
  avg_dist <- vector()
  for (i in 1:length(obj)) {
    avg_edges[i] <- obj[[i]]$average_edges_connected_to_node
    avg_dist[i] <- obj[[i]]$average_distance
  }
  plot(x, avg_edges, type='l', main='Average edges per node', xlab='days', ylab='edges')
  plot(x, avg_dist, type='l', main='Average distance', xlab='days', ylab='distance (km)')
}