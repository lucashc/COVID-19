source('./scripts/experimental/graph.R')
library(progress)
# Steps for simulation
# 1. Initalize graph, set states
# 2. Timestep
# 2a. Choose newly infected, check recovery (prob density) or direct
# 2b. Make new edges if necessary


# 1
n <- 10000
initial_infections <- 10
n_days <- 10
infection_prob <- 0.14
lambda <- 1
alpha <- 1

node_data <- generate_node_data(n, recovery_time=rep.int(0,n))
graph <- generate_empty_graph(n)

initial_infected = sample(nrow(node_data), initial_infections)
node_data[initial_infected, "status"] <- 'J'
node_data[initial_infected, "recovery_time"] <- 14
node_data[initial_infected, "death_time"] <- 14


history <- data.frame(S=n-initial_infections, I=0, R=0, D=0, J=initial_infections)

# 2
pb <- progress_bar$new(total = n_days, format='Simulating [:bar] :percent eta: :eta')
pb$tick(0)
for (i in 1:n_days) {
  # a
  # Get list of infected
  statusI <- node_data$status == 'I'
  statusR <- node_data$recovery_time <= i
  statusD <- node_data$death_time <= i

  infected <- which(statusI)
  recovered <- which(statusI && statusR)
  dead <- which(statusI && statusD)
  newlyinfected <- which(node_data$status == 'J')
  susceptible <- which(node_data$status == 'S')
  
  # Check recovery and death otherwise increment
  node_data[dead, "status"] <- 'D'
  node_data[recovered, "status"] <- 'R'
  
  # Make edges to new people if they are not infected
  for (sick in newlyinfected) {
    for (healthy in susceptible) {
      if (connect(sick, healthy, alpha, lambda)) {
        graph <- make_edge(graph, sick, healthy)
      }
    }
  }
  
  node_data[newlyinfected,"status"] = "I"
  
  # Infect people
  for (node in infected) {
    for (neighbour in graph[[node]]) {
      if (node_data[neighbour,"status"] == 'S') {
        if (runif(1)[1] < infection_prob) {
          node_data[neighbour,"status"] <- 'J'
          node_data[neighbour,"recovery_time"] <- i + 14
        }
      }
    }
  }
  
  # Log data
  history[nrow(history) + 1,] <- c(
    sum(node_data$status == "S"),
    sum(node_data$status == "I"),
    sum(node_data$status == "R"),
    sum(node_data$status == "D"),
    sum(node_data$status == "J")
  )
  pb$tick()
}
print(history)
print(sum(as.numeric(lapply(graph, length))))