source('./scripts/experimental/geodata.R')
library(ggplot2)
library(reshape2)

plotSIRJ <- function(history, title="SIRJ-plot", S=TRUE, I=TRUE, R=TRUE, J=TRUE) {
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  print(vars)
  mhist <- melt(history, id='day', measure.vars = vars)
  names(mhist) <- c('day', 'casetype', 'cases')
  fig <- ggplot(mhist, aes(x=day, y=cases, color=casetype)) + geom_line() + labs(title=title, x='days', y='cases')
  print(fig)
  fig
}

plotHeatMap<- function(node_data, title="Heat map of infections", from=1) {
  raw_data <- node_data[node_data$status == 2, c('x', 'y')]
  geo <- geo.getMask()
  geo <- t(apply(geo, 2, rev))
  geo <- geo*0
  jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
  d1 <- ggplot()
  d1 <- d1 + geom_tile(data=melt(geo), mapping=aes(x=Var1, y=Var2, fill=value))
  d1 <- d1 + geom_bin2d(data=raw_data, aes(x, y), binwidth=10) + scale_fill_gradientn(colors=jet.colors(7))
}