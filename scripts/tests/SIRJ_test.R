source('./scripts/RGG/source.R')

data <- list()

for (i in 1:5) {
  result <- simulate(n=1e6, n_days = 20, initial_infections = 10)$history
  data[[i]] <- result
}

plotConfidenceSIRJ(data, S=FALSE)