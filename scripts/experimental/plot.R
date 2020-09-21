library(ggplot2)
library(reshape2)

plotSIRJ <- function(history, title="SIRJ-plot", S=TRUE, I=TRUE, R=TRUE, J=TRUE) {
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  mhist <- melt(history, id='day', measure.vars = vars)
  names(mhist) <- c('day', 'casetype', 'cases')
  fig <- ggplot(mhist, aes(x=day, y=cases, color=casetype)) + geom_line() + labs(title=title, x='days', y='cases')
  print(fig)
  fig
}