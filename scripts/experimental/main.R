source('scripts/experimental/simulate.R')
source('./scripts/experimental/plot.R')
library(EnvStats)

n <- 1e6

weights <- rpareto(n, 3/4, 4)

result <- simulate(monitor = TRUE, weights=weights, lambda=1e-3)

# print(result$history)
diag <- graph_diagnostics(result$graph, result$node_data, groups = c(1,2))
print(diag)
plot(diag)

plot(result$diagnostic_history)

plotSIRJ(result, S=FALSE)
plotHeatMap(result, from = 2)