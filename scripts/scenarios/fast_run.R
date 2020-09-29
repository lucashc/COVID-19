source("./scripts/RGG/source.R")
library(EnvStats)
infsAt20 = c()
recAt20 = c()
newAt20 = c()
n = 1e6
RUNS = 30
for (i in (1:RUNS)){
  print(i)
  result <- simulate(n = n, 
                     monitor = FALSE, 
                     weights = rpareto(n, 3/4, 4),
                     lambda = 0.00128125, # Found with binary search
                     n_days = 20, 
                     infection_prob = 0.025,
                     lpois = 14,
                     initial_infections = 25
                  
  )
  
  infsAt20[i] <- result$history[length(result$history$day)-1,'I']
  recAt20[i] <- result$history[length(result$history$day)-1,'R']
  newAt20[i] <- result$history[length(result$history$day)-1,'J']
  
}

par(mfrow=c(1,3))
hist(infsAt20)
hist(recAt20)
hist(newAt20)
sprintf('mean infs: %f', mean(infsAt20))
sprintf('mean recs: %f', mean(recAt20))
sprintf('mean J: %f', mean(newAt20))
