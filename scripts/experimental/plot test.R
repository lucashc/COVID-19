
plotgraph <- function(bigdataboi,axbool = FALSE, dotsize = 1) {
  #split data
  xinf <- bigdataboi[which(bigdataboi$status=='I'),]$x
  yinf <- bigdataboi[which(bigdataboi$status=='I'),]$y
  xsus <- bigdataboi[which(bigdataboi$status=='S'),]$x
  ysus <- bigdataboi[which(bigdataboi$status=='S'),]$y
  xrec <- bigdataboi[which(bigdataboi$status=='R'),]$x
  yrec <- bigdataboi[which(bigdataboi$status=='R'),]$y
  xded <- bigdataboi[which(bigdataboi$status=='D'),]$x
  yded <- bigdataboi[which(bigdataboi$status=='D'),]$y
  #plot data separately per color
  plot(xinf,yinf, pch = 21, col = "black", cex = dotsize, bg = 'red', xlim = c(0,10), ylim = c(0,10),axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xsus,ysus, pch = 21, col = "black", cex = dotsize, bg = 'blue', xlim = c(0,10), ylim = c(0,10),axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xrec,yrec, pch = 21, col = 'black', cex = dotsize, bg = "green", xlim = c(0,10), ylim = c(0,10),axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xded,yded, pch = 4, col = 'red', cex = dotsize, xlab='',ylab='',axes=FALSE, xlim = c(0,10), ylim = c(0,10))
  #connect contacting points
  segments(3,4,c(3,5),c(7,2))
}


bigdataboi <- data.frame(x = c(1,3,5,3), y = c(1,7,2,4), W = c(0.1,0.5,0.2,0), status=c('D','I','S','R'))

plotgraph(bigdataboi, FALSE)