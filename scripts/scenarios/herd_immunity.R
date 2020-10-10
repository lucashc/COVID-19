source("./scripts/RGG/source.R")
library(EnvStats)

n = 1e3
j = 20

steadystate <- array(0:j)

for (i in 1:j){

  result <- simulate(n = n, 
                     monitor = TRUE, 
                     weights = rpareto(n, 3/4, 4),
                     lambda = 1.36, # Found with binary search
                     n_days = 125, 
                     infection_prob = 0.023,
                     lpois = 14,
                     initial_infections = i,
                     initial_immune = 10
  )
  
  # diag <- graph_diagnostics(result$graph, result$node_data, groups = c(2,3))
  # print(diag)
  # plot(diag)
  # fit_diagnostics(diag)
  # 
  # plot(result$diagnostic_history)
  # 
  # plotSIRJ(result, S=TRUE)
  # plotHeatMap(result, start_nodes = TRUE)
  # 
  # # Save results from run
  # save_result(result, prefix="Herd immunity")
  # # Print day before last

  steadystate[i] <- result$history[length(result$history$day)-1,2]
  print(i)
}

steadystate <- steadystate/n*100
ilist <- seq(0,j)/j*100
plot(ilist,steadystate, xlab = 'Percentage of initial infections', ylab = 'Percentage of susceptible individuals', xlim = c(0,100), ylim = c(0,100),xaxs="i",
     yaxs="i")

xylm <- lm(steadystate~ilist)
abline(coefficients(xylm),col=3)
summary(xylm)