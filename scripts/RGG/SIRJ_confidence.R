library(ggplot2)
source("./scripts/functions/datatools.R")


getBand <- function(df, t='S', confint=0.95) {
  dat <- as.matrix(df[,grep(sprintf('^%s', t), colnames(df))])
  percentilelow <- (1-confint)/2
  percentilehigh <- 1-percentilelow
  newdat <- data.frame(df$day, apply(dat, 1, mean), apply(dat, 1, quantile, percentilelow), apply(dat, 1, quantile, percentilehigh))
  names(newdat) <- c('day', 'mean', 'low', 'high')
  return(newdat)
}

plotTypeConf <- function(pl, total, t='S', confint=0.95) {
  data <- getBand(total, t, confint)
  pl <- pl + geom_line(aes(x=day, y=mean, color=t), data=data) + geom_ribbon(aes(x=day, ymin=low, ymax=high, fill=t), data=data, alpha=0.35)
  return(pl)
}


plotConfidenceSIRJ <- function(histories, S=TRUE, I=TRUE, R=TRUE, J=TRUE, confint=0.95, title='SIRJ plot 95% interval', special_theme=FALSE) {
  total <- data.frame(histories)
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  pl <- ggplot()
  for (t in vars) {plot
    pl <- plotTypeConf(pl, total, t, confint)
  }
  scale <- c(
    'S' = 'blue',
    'I' = 'red',
    'J' = 'orange',
    'R' = 'green'
  )
  pl <- pl + scale_color_manual(values = scale) + scale_fill_manual(values=scale) + labs(title=title, x='days', y='cases', fill='', colour='')
  if (special_theme) {
    library(showtext)
    font_add('lmodern', regular = '/usr/share/fonts/TTF/cmunrm.ttf')
    showtext_auto()
    pl <- pl + theme(rect=element_rect(fill="transparent", color="transparent"), 
                     axis.title.x = element_text(family="lmodern", colour='white', size=rel(10)),
                     axis.title.y = element_text(family="lmodern", colour='white', size=rel(10)),
                     plot.background = element_rect(fill="transparent", colour='transparent'),
                     panel.background = element_rect(fill="transparent", colour='transparent'),
                     plot.title = element_text(family="lmodern", colour='white', size = rel(20)),
                     legend.text = element_text(family="lmodern", colour='white', size=rel(8)),
                     legend.title=element_text(family="lmodern", colour='white', size=rel(10)),
                     axis.text = element_text(family='lmodern', colour='white', size=rel(8))
    )
  }
  
  return(pl)
}

plotConfJRKI <- function(histories, start, end, scale, confint=0.95) {
  IDR <- rki.getIDR(rki.load())
  total <- data.frame(histories)
  indices <- grep('^J', colnames(total))
  total[,indices] <- total[,indices]*scale
  pl <- ggplot()
  pl <- plotTypeConf(pl, total, 'J', confint)
  pl <- pl + geom_point(aes(x=0:(end-start), y=infections, color='RKI'), data=IDR[start:end,], shape=3)
  scale <- c(
    'J' = 'orange',
    'RKI' = 'black'
  )
  pl <- pl + scale_color_manual(values = scale) + scale_fill_manual(values=scale) + labs(title='Infections plot 95% interval', x='days', y='cases', fill='', colour='') + guides(fill=FALSE, shape=FALSE)
  return(pl)
}

plotConfCumRKI<- function(h, start, end, scale, confint=0.95) {
  IDR <- rki.getIDR(rki.load())
  IDR$infections <- cumsum(IDR$infections)
  total <- list()
  for (i in 1:length(h)) {
    new_subtotal <- data.frame(h[[i]]$day, (h[[i]]$I+h[[i]]$R+h[[i]]$J)*scale)
    names(new_subtotal) <- c('day', 'cum')
    total[[i]] <- new_subtotal
  }
  total <- data.frame(total)
  pl <- ggplot()
  pl <- plotTypeConf(pl, total, t='cum', confint) + geom_point(aes(x=0:(end-start), y=infections, color='RKI'), data=IDR[start:end,], shape=3)
  scale <- c(
    'cum' = 'blue',
    'RKI' = 'black'
  )
  pl <- pl + scale_color_manual(values = scale) + scale_fill_manual(values=scale) + labs(title='Cumulative infections', x='days', y='cases', fill='', colour='') + guides(fill=FALSE, shape=FALSE)
  return(pl)
}
