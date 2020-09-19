source('./scripts/experimental/graph.R')
# Steps for simulation
# 1. Initalize graph, set states
# 2. Timestep
# 2a. Choose newly infected, check recovery (prob density) or direct
# 2b. Make new edges if necessary


# 1
n <- 100
initial_infections <- 2
n_days <- 100
infection_prob <- 1

node_data <- generate_node_data(n, recovery_time=rep.int(0,n))
graph <- generate_empty_graph(n)

node_data[sample(nrow(node_data), initial_infections),]$status <- 'I'

history <- data.frame(S=n-initial_infections, I=initial_infections, R=0, D=0)

# 2
for (i in 1:n_days) {
  # a
  # Get list of infected
  infected <- which(node_data$status == 'I')
  
  # Check recovery and death otherwise increment
  for (node in infected) {
    if (node_data[node,]$recovery_time > 14) {
      node_data[node,]$status <- 'R'
      next
    }
    if (node_data[node,]$recovery_time < 0) {
      node_data[node,]$status <- 'D'
      next
    }
    node_data[node,]$recovery_time <- node_data[node,]$recovery_time + 1
  }
  
  # Make edges to new people if they are not infected
  for (other in 1:n) {
    for (node in infected) {
      if (node == other) {
        next
      }
      if (connect(other, node, lambda = 1) && node_data[other,]$status == 'S') {
        graph <- make_edge(graph, node, other)
      }
    }
  }
  # Infect people
  for (node in infected) {
    for (neighbour in graph[[node]]) {
      if (node_data[neighbour,]$status == 'S') {
        if (runif(1)[1] < infection_prob) {
          node_data[neighbour,]$status <-'I'
        }
      }
    }
  }
  
  # Log data
  history[nrow(history) + 1,] <- c(
    sum(node_data$status == "S"),
    sum(node_data$status == "I"),
    sum(node_data$status == "R"),
    sum(node_data$status == "D")
  )
}
print(history)
