source("./scripts/experimental/geodata.R")

generate_node_data <- function(n, weights = rep.int(1, n), accuracy = 1000){
  sample = geo.sample(n, accuracy)
  x <- sample$x
  y <- sample$y
  node_data <- data.frame(weights, x, y)
  names(node_data) <- c('weight', 'x', 'y')
  return(node_data)
}



generate_empty_graph <- function(n){
  graph = list()
  for (i in 1:n){
    graph[[i]] <-  vector()
  }
  return(graph)
}


distance_c <- function(node1, node2){
  x = node_data$x
  y = node_data$y
  return((x[node1]-x[node2])**2 + (y[node1]-y[node2])**2)**0.5
}



connect <- function(node1, node2, alpha = 1, lambda = 1){
  w = node_data$weight
  p <- runif(1, 0, 1)[1]
  prob <- 1 - exp(-lambda*w[node1]*w[node2]/(distance_c(node1, node2))^alpha)
  return(p < prob)
}
