source('./scripts/experimental/graph.R')
library(progress)

# Make reproducible
set.seed(1)

search <- function(n, sample_size, lambda, alpha) {
  
  node_data <- generate_simple_node_data(n)
  
  sampled = sample(nrow(node_data), sample_size)
  total_edges = 0

  for (s in sampled) {
    susceptible = s+1:n
    total_edges = total_edges + sum(connect(node_data, s, susceptible, alpha, lambda))
  }
  print(total_edges)
  return(total_edges/sample_size)
}

average_avg_edges <- function(alpha, n, lambda, shots = 5) {
  x = replicate(shots, search(n, n, lambda, alpha))
  print(sprintf("variance: %f", var(x)))
  return(mean(x))
}

alpha = 1.5*0.5
n = 10000
step = 1
lambda = 0
target = 7.95
guess = average_avg_edges(alpha, n, step)
while(guess < target) {
  step = step * 2
  guess = average_avg_edges(alpha, n, step)
  print(sprintf("guess: %.2f", guess))
}
while(abs(guess - target) > 0.1) {
  step = step/2
  guess = average_avg_edges(alpha, n, lambda + step)
  if (guess < target) {
    lambda = lambda + step
    print(sprintf("lambda: %.2f", lambda))
  }
  print(sprintf("guess: %.2f", guess))
}

print(sprintf("lambda: %.2f", lambda))
