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

  # diag <- graph_diagnostics(result$graph, result$node_data, groups = c(2,3))
  # print(diag)
  # plot(diag)
  # fit_diagnostics(diag)
  # 
  # plot(result$diagnostic_history)
  # 
  # plotSIRJabs(result, S=TRUE)
  # plotHeatMap(result, start_nodes = TRUE)
  # 
  # # Save results from run
  # save_result(result, prefix="Herd immunity")
  # # Print day before last

  plotSIRJabs(result, S=TRUE)
  
  steadystate[i] <- result$history[length(result$history$day)-1,2]
  infevo <- result$history[1:31,3]
  infevo[infevo == 0] <- NA
  infevo <- infevo[!is.na(infevo)]
  v <- 1:length(infevo)
  plot(v, infevo)
  infevolm <- lm(log(infevo)~v)
  Karr[i] <- infevolm$coefficients[2]
  print(i)
}

steadystate <- steadystate/1000

ilist <- seq(1,j)*5/100
plot(ilist,steadystate, xlab = 'Percentage of initially immune individuals', ylab = 'Percentage of susceptible individuals at the end', xlim = c(0,1), ylim = c(0,1),xaxs="i",
     yaxs="i",col=1)

values <- matrix(c(ilist,steadystate), ncol=2)
barplot(t(values),names.arg=ilist)

xylm <- lm(steadystate+ilist~ilist)
abline(coefficients(xylm),col=4)
summary(xylm)

R0arr <- exp(Karr[0:990]*tau)
index <- (1:(n-10))/n*100

R0lm <- lm(R0arr~index)
plot(index,R0arr, xlab = 'Percentage of initially immune individuals', ylab = 'R0', xlim = c(0,100), ylim = c(0,3),xaxs="i",
     yaxs="i",col=1)
abline(coefficients(R0lm),col=2)
abline(1,0,col=3)

hit <- -(coefficients(R0lm)[1]-1)/coefficients(R0lm)[2]/n
print(hit)
