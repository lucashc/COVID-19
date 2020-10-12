source("./scripts/RGG/source.R")
library(EnvStats)

plotSIRJabs <- function(obj, title="SIRJ-plot", S=TRUE, I=TRUE, R=TRUE, J=TRUE) {
  history <- obj$history
  vars <- c('S', 'I', 'R', 'J')[c(S, I, R, J)]
  mhist <- melt(history, id='day', measure.vars = vars)
  names(mhist) <- c('day', 'casetype', 'cases')
  fig <- ggplot(mhist, aes(x=day, y=cases, color=casetype)) + geom_line() + labs(title=title, x='days', y='cases')
  print(fig + coord_cartesian(xlim =c(0, 250), ylim = c(0, 1000)))
  #fig
}

n = 1e3
j = 1000
tau = 6

steadystate <- array(1:j-10)
Karr <- array(1:j-10)

for (i in 1:(j-10)){
  
  result <- simulate(n = n, 
                     monitor = TRUE, 
                     weights = rpareto(n, 3/4, 4),
                     lambda = 1.36, # Found with binary search
                     n_days = 250, 
                     infection_prob = 0.023,
                     lpois = 14,
                     initial_infections = 5,
                     initial_immune = n/j*i
  )
  
  png(filename=paste(toString(i),".png",sep=''))
  plotSIRJabs(result, S=TRUE)
  dev.off()
  print(i)
}
