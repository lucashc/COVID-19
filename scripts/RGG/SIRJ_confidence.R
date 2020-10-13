library(ggplot2)


getBand <- function(df, t='S') {
  dat <- as.matrix(df[,grep(sprintf('^%s', t), colnames(df))])
  newdat <- data.frame(df$day, apply(dat, 1, mean), apply(dat, 1, quantile, 0.025), apply(dat, 1, quantile, 0.975))
  names(newdat) <- c('day', 'mean', 'low', 'high')
  return(newdat)
}

plotTypeConf <- function(pl, total, t='S') {
  data <- getBand(total, t)
  pl <- pl + geom_line(aes(x=day, y=mean, color=t), data=data) + geom_ribbon(aes(x=day, ymin=low, ymax=high, fill=t), data=data, alpha=0.2)
  return(pl)
}


plotConfidenceSIRJ <- function(histories, S=TRUE, I=TRUE, R=TRUE, J=TRUE) {
  total <- data.frame(histories)
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  pl <- ggplot()
  for (t in vars) {
    pl <- plotTypeConf(pl, total, t)
  }
  scale <- c(
    'S' = 'green',
    'I' = 'red',
    'J' = 'orange',
    'R' = 'blue'
  )
  pl <- pl + scale_color_manual(values = scale) + scale_fill_manual(values=scale) + labs(title='SIRJ plot', x='days', y='cases', fill='', colour='')
  return(pl)
}