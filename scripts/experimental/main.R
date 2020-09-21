source('./scripts/experimental/graph.R')
source('./scripts/experimental/plot.R')
library(progress)
# Steps for simulation
# 1. Initalize graph, set states
# 2. Timestep
# 2a. Choose newly infected, check recovery (prob density) or direct
# 2b. Make new edges if necessary


# 1
n <- 100000
initial_infections <- 10
n_days <- 20
infection_prob <- 0.05
lambda <- 0.02
alpha <- 0.5

node_data <- generate_node_data(n, recovery_time=rep.int(0,n))
graph <- generate_empty_graph(n)

initial_infected = sample(nrow(node_data), initial_infections)
node_data[initial_infected, "status"] <- 'J'
node_data[initial_infected, "recovery_time"] <- 14

history <- data.frame(day=0, S=n-initial_infections, I=0, R=0, J=initial_infections)

# 2
pb <- progress_bar$new(total = n_days, format=" Simulating [:bar] :percent :current/:total I: :I J: :J")
pb$tick(0, tokens=list(I=0, J=initial_infections))
for (i in 1:n_days) {
  statusI <- node_data$status == 'I'
  statusR <- node_data$recovery_time <= i

  infected <- which(statusI)
  newlyinfected <- which(node_data$status == 'J')
  susceptible <- which(node_data$status == 'S')
  
  # Handle recovery
  recovered <- which(statusI & statusR)
  node_data[recovered, "status"] <- 'R'
  
  # Make edges to new people if they are not infected
  for (sick in newlyinfected) {
    graph[[sick]] <- susceptible[connect(sick, susceptible, alpha, lambda)]
  }
  
  node_data[newlyinfected,"status"] = "I"
  
  # Infect people
  for (node in infected) {
    neighbours <- graph[[node]]
    susneighs <- neighbours[which(node_data[neighbours,"status"] == 'S')]
    infneighs <- susneighs[runif(length(susneighs)) < infection_prob]
    node_data[infneighs,"status"] <- 'J'
    node_data[infneighs,"recovery_time"] <- i + 14
  }
  
  # Log data
  new_n_inf <- sum(node_data$status == "J")
  old_n_inf <- sum(node_data$status == "I")
  history[nrow(history) + 1,] <- c(i,
    sum(node_data$status == "S"),
    old_n_inf,
    sum(node_data$status == "R"),
    new_n_inf
  )
  pb$tick(tokens=list(J=new_n_inf, I=old_n_inf))
}
print(history)
diagnostics(graph)
plotSIRJ(history, S=FALSE)
