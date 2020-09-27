source('scripts/experimental/simulate.R')
source('./scripts/experimental/plot.R')
result <- simulate()

print(result$history)
diag <- graph_diagnostics(result$graph, result$node_data, groups = c(1,2))
print(diag)
plot(diag)

plotSIRJ(result, S=FALSE)
plotHeatMap(result, from = 2)