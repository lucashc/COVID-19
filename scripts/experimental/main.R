source("./scripts/experimental/source.R")
library(EnvStats)

n <- 1e6

weights <- rpareto(n, 3/4, 4)

result <- simulate(monitor = TRUE, weights=weights, lambda=1e-3)

# print(result$history)
diag <- graph_diagnostics(result$graph, result$node_data, groups = c(2,3))
print(diag)
plot(diag)

plot(result$diagnostic_history)

plotSIRJ(result, S=FALSE)
plotHeatMap(result, start_nodes = TRUE)


