source("./scripts/RGG/source.R")
library(EnvStats)

n = 1e4

result <- simulate(n = n, 
                   monitor = TRUE, 
                   lambda = 0.256, # Found with binary search
                   n_days = 30, 
                   infection_prob = 0.05,
                   lpois = 14,
                   initial_infections = 25
)

diag <- graph_diagnostics(result$graph, result$node_data, groups = c(2,3))
print(diag)
plot(diag)

plot(result$diagnostic_history)

plotSIRJ(result, S=FALSE)
plotHeatMap(result, start_nodes = TRUE)

# Save results from run
save_result(result, prefix='Initial spread')
# Print day before last
print(result$history[length(result$history$day)-1,])