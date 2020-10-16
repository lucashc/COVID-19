library(ggplot2)
source("./scripts/functions/datatools.R")


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
    'S' = 'blue',
    'I' = 'red',
    'J' = 'orange',
    'R' = 'green'
  )
  pl <- pl + scale_color_manual(values = scale) + scale_fill_manual(values=scale) + labs(title='SIRJ plot 95% interval', x='days', y='cases', fill='', colour='')
  return(pl)
}

plotConfJRKI <- function(histories, start, end, scale) {
  IDR <- rki.getIDR(rki.load())
  total <- data.frame(histories)
  total[,'J'] <- total[,'J']*scale
  pl <- ggplot()
  pl <- plotTypeConf(pl, total, 'J')
  pl <- pl + geom_point(aes(x=0:(end-start), y=infections, color='RKI'), data=IDR[start:end,], shape=3)
  scale <- c(
    'S' = 'blue',
    'I' = 'red',
    'J' = 'orange',
    'R' = 'green',
    'RKI' = 'black'
  )
  pl <- pl + scale_color_manual(values = scale) + scale_fill_manual(values=scale) + labs(title='Infections plot 95% interval', x='days', y='cases', fill='', colour='') + guides(fill=FALSE, shape=FALSE)
  return(pl)
}