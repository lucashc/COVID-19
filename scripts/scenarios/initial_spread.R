source("./scripts/RGG/source.R")
library(EnvStats)

result <- simulate(n = 1e6, 
                   monitor = TRUE, 
                   weights = rpareto(n, 3/4, 4),
                   lambda = 0.00128125, # Found with binary search
                   n_days = 20, 
                   infection_prob = 0.0125,
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