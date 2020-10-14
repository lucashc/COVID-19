source('./scripts/RGG/source.R')

data <- list()

for (i in 1:5) {
  result <- simulate(n = n, 
                      monitor = TRUE, 
                      weights = rpareto(n, 3/4, 4),
                      lambda = 0.00128125, # Found with binary search
                      n_days = 20, 
                      infection_prob = 0.023,
                      lpois = 14,
                      initial_infections = 30
  )$history
  data[[i]] <- result
}

plotConfidenceSIRJ(data, S=FALSE)