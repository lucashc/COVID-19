n <- 50
lambda <- 1
alpha <- 1


weights <- rep.int(1, n)
x <- rnorm(n, 0, 10)
y <- rnorm(n, 0, 10)
node_data <- data.frame(weights, x, y)
names(node_data) <- c('weight', 'x', 'y')


graph = list()
for (i in 1:n){
  graph[[i]] <-  c(0)
}




distance <- function(node1, node2){
  x = node_data$x
  y = node_data$y
  return ((x[node1]-x[node2])**2 + (y[node1]-y[node2])**2)**0.5
}



connect <- function(node1, node2){
  w = node_data$weight
  p <- runif(1, 0, 1)
  prob <- 1 - exp(-lambda*w[node1]*w[node2]/(distance(node1, node2))^alpha)
  if(p < prob) {
    return(TRUE)
  }
  else {
    return(FALSE)
  }
}



for (node1 in 1:n){
  for (node2 in 1:n){
    if (node1 == node2){
      next
    }
    if (connect(node1, node2)){
      graph[node1] = c(graph[node1], node2)
      graph[node2] = c(graph[node2], node1)
    }
  }
}

print(graph)
