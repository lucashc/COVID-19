source('./scripts/RGG/graph.R')
library(progress)
library(parallel)
library(EnvStats)

# Make reproducible
set.seed(1)

ncores = 4

search <- function(n, sample_size, lambda, alpha, node_data = NA) {
  if (is.na(node_data)){node_data <- generate_simple_node_data(n, weights = rpareto(n, 3/4, 4))}
  
  sampled = sample(nrow(node_data), sample_size)
  
  total_edges = 0
  for (s in sampled) {
    if (s == n) {next}
    susceptible = (s+1):n
    total_edges = total_edges + sum(connect(node_data, s, susceptible, alpha, lambda))
  }
  
  return(total_edges/sample_size)
}

average_avg_edges <- function(alpha, n, lambda, sample_size, shots = 5, accuracy = 1000) {
  node_data = generate_simple_node_data(n)
  x = mcmapply(function(s) {search(n, sample_size, lambda, alpha, node_data)}, 1:shots, mc.cores = ncores)
  print(sprintf("standard deviation: %f", sd(x)))
  return(mean(x))
}

find_lambda <- function(n, alpha, sample_size, step=1, shots = 8, target = 7.95, accuracy = 1000) {
  lambda = 0
  guess = average_avg_edges(alpha, n, step, sample_size, shots, accuracy)
  while(guess < target) {
    step = step * 2
    guess = average_avg_edges(alpha, n, step, sample_size, shots, accuracy)
    print(sprintf("guess: %f", guess))
    print(sprintf("step: %f", step))
  }
  while(abs(guess - target) > 0.1) {
    step = step/2
    guess = average_avg_edges(alpha, n, lambda + step, sample_size, shots, accuracy)
    if (guess < target) {
      lambda = lambda + step
      print(sprintf("lambda: %f", lambda))
    }
    print(sprintf("guess: %f", guess))
  }
  
  print(sprintf("%i: final lambda: %f", n, lambda))
  return(lambda)
}


# lambdas = data.frame("n" = 2:20*500, "lambda"= rep(0, 19))
# for (i in 1:nrow(lambdas)) {
#   lambdas$lambda[i] = find_lambda(lambdas$n[i], 0.5, lambdas$n[i])
# }
# print(lambdas)
print("Starting")
print(find_lambda(1e4, 0.5, 1e4, 0.002))
