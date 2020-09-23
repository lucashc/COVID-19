source('./scripts/experimental/graph.R')
#source('./scripts/experimental/plot.R')
library(progress)
library(parallel)
# Steps for simulation
# 1. Initalize graph, set states
# 2. Timestep
# 2a. Choose newly infected, check recovery (prob density) or direct
# 2b. Make new edges if necessary

# Make reproducible
set.seed(1)

# Check if Windows or Linux
if (.Platform$OS.type == "unix") {
  # Parallel execution works
  ncores <- 4
  print("Running on UNIX, enable multi core support")
}else {
  ncores <- 1
  print("Running on Windows, disable multi core support")
}

# 1
n <- 1e6
initial_infections <- 10
n_days <- 20
infection_prob <- 0.05
lambda <- 1e-3
lpois <- 14
alpha <- 0.5

node_data <- generate_node_data(n, recovery_time=rep.int(0,n))
graph <- generate_empty_graph(n)
recoverytime <- 1 + rpois(n, lpois)

initial_infected = sample(nrow(node_data), initial_infections)
node_data[initial_infected, "status"] <- 1
node_data[initial_infected, "recovery_time"] <- 14

history <- data.frame(day=0, S=n-initial_infections, I=0, R=0, J=initial_infections)

# 2
pb <- progress_bar$new(total = n_days, format=" Simulating [:bar] :percent :current/:total I: :I J: :J")
pb <- pb$tick(0, tokens=list(I=0, J=initial_infections))
for (i in 1:n_days) {
  statusI <- node_data$status == 2
  statusR <- node_data$recovery_time <= i

  infected <- which(statusI)
  newlyinfected <- which(node_data$status == 1)
  susceptible <- which(node_data$status == 0)
  
  # Handle recovery
  recovered <- which(statusI & statusR)
  node_data[recovered, "status"] <- 3
  
  # Make edges to new people if they are not infected
  # Works parallel on Linux
  graph[newlyinfected] <- mclapply(newlyinfected, function(sick) {susceptible[connect(node_data, sick, susceptible, alpha, lambda)]}, mc.cores = ncores)
  # Serial execution
  # for (sick in newlyinfected) {
  #   graph[[sick]] <- susceptible[connect(node_data, sick, susceptible, alpha, lambda)]
  # }

  node_data[newlyinfected,"status"] = 2
  
  # Infect people
  for (node in infected) {
    neighbours <- graph[[node]]
    susneighs <- neighbours[which(node_data[neighbours,"status"] == 0)]
    infneighs <- susneighs[runif(length(susneighs)) < infection_prob]
    node_data[infneighs,"status"] <- 1
    node_data[infneighs,"recovery_time"] <- i + recoverytime[infneighs]
  }
  
  # Log data
  new_n_inf <- sum(node_data$status == 1)
  old_n_inf <- sum(node_data$status == 2)
  history[nrow(history) + 1,] <- c(i,
    sum(node_data$status == 0),
    old_n_inf,
    sum(node_data$status == 3),
    new_n_inf
  )
  pb$tick(tokens=list(J=new_n_inf, I=old_n_inf))
}

print(history)
