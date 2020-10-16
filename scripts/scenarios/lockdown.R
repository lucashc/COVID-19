source("./scripts/RGG/source.R")
library(EnvStats)

n = 1e6

result <- simulate(n = n, 
                   monitor = TRUE, 
                   weights = rpareto(n, 3/4, 4),
                   lambda = 0.00128125, # Found with binary search
                   n_days = 100, 
                   infection_prob = function(t, s, j) {
                     if (t < 20) {
                       return(0.024)
                     } else {
                       return(0.006)
                     }
                   },
                   lpois = 14,
                   initial_infections = 25 # day 25 in rki data
)

# diag <- graph_diagnostics(result$graph, result$node_data, groups = c(2,3))
# print(diag)
# plot(diag)

# plot(result$diagnostic_history)

# plotSIRJ(result, S=FALSE)
# plotHeatMap(result, start_nodes = TRUE)

# Save results from run
# save_result(result, prefix='Initial spread')
# Print day before last
# print(result$history[length(result$history$day)-1,])
rki.cumsum_plot(100)
lines(25:125,(result$history$I + result$history$R + result$history$J)*80)
lines(29:123, moving_average((result$history$I + result$history$R + result$history$J)*80, 7))
IDR = rki.getIDR(rki.load())
print((result$history$I + result$history$R + result$history$J)*80 - cumsum(IDR$infections)[25:125])