source("./scripts/RGG/source.R")
library(EnvStats)

n = 1e6
start_day = 25
end_day = 125
shots = 60

histories <- list()

for (i in 1:shots) {
  print(sprintf("At shot %d of %d", i, shots))
  result <- simulate(n = n, 
                    monitor = FALSE, # Save memory
                    record_infected = FALSE, # Save memory
                    weights = rpareto(n, 3/4, 4),
                    lambda = 0.00128125, # Found with binary search
                    n_days = end_day-start_day, 
                    infection_prob = function(t, s, j) {
                                        if (t < 20) {
                                          return(0.026)
                                        } else {
                                          return(0.005)
                                        }
                                      },
                    lpois = 14,
                    initial_infections = 25 # day 25 in rki data
                    )
  histories[[i]] <- result$history
  save_result(result, 'largerun', toString(i))
  rm(result)
}
save_result(histories, "histories", "60")
plotConfCumRKI(histories, start_day, end_day, 80)
