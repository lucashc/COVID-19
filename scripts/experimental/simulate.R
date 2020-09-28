source('./scripts/experimental/graph.R')
library(progress)
library(parallel)
library(EnvStats)
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
  ncores <- 8
  print("Running on UNIX, enable multi core support")
}else {
  ncores <- 1
  print("Running on Windows, disable multi core support")
}


simulate <- function(n=1e6, initial_infections=10, n_days=20, infection_prob=0.05, lambda=1e-3, alpha=0.5, lpois=14, monitor=FALSE, weights=rep.int(1, n)) {
  
  node_data <- generate_node_data(n, recovery_time=rep.int(0,n), weights = weights)
  graph <- generate_empty_graph(n)
  recoverytime <- 1 + rpois(n, lpois)
  
  initial_infected = sample(nrow(node_data), initial_infections)
  node_data[initial_infected, "status"] <- 1
  node_data[initial_infected, "recovery_time"] <- recoverytime[initial_infected]
  
  history <- data.frame(day=0, S=n-initial_infections, I=0, R=0, J=initial_infections)
  
  if (monitor) {
    diagnostic_history <- list()
    diagnostic_history[[1]] <- graph_diagnostics(graph, node_data)
    startnode_data <- node_data
    class(diagnostic_history) <- "diagnostic_history"
  }
  
  # 2
  pb <- progress_bar$new(total = n_days, format=" Simulating [:bar] :percent :current/:total :elapsed I: :I J: :J")
  pb <- pb$tick(0, tokens=list(I=0, J=initial_infections))
  for (i in 1:n_days) {
    # Make edges to new people if they are not infected. This works parallel on Linux.
    susceptible <- which(node_data$status == 0)
    newlyinfected <- which(node_data$status == 1)
    graph[newlyinfected] <- mclapply(newlyinfected, function(sick) {susceptible[connect(node_data, sick, susceptible, alpha, lambda)]}, mc.cores = ncores)
    
    node_data[newlyinfected,"status"] = 2
    
    statusI <- node_data$status == 2
    statusR <- node_data$recovery_time <= i
  
    infected <- which(statusI)
    
    # Handle recovery
    node_data[statusI & statusR, "status"] <- 3
    
    # Infect people
    infneighs = do.call(c, mapply(function(node){
      neighbours <- graph[[node]]
      susneighs <- neighbours[which(node_data[neighbours,"status"] == 0)]
      return(susneighs[runif(length(susneighs)) < infection_prob])
    },infected))

    node_data[infneighs,"status"] <- 1
    node_data[infneighs,"recovery_time"] <- i + recoverytime[infneighs]
    
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
    if (monitor) {
      diagnostic_history[[i+1]] <- graph_diagnostics(graph, node_data)
    }
    # Try garbage collection each loop
    rm(susceptible)
    rm(newlyinfected)
    rm(statusI)
    rm(statusR)
    rm(infneighs)
    rm(infected)
    rm(new_n_inf)
    rm(old_n_inf)
  }
  result <- list(graph=graph, node_data=node_data, history=history, diagnostic_history=NULL)
  class(result) <- "simulation_results"
  if (monitor) {
    result$diagnostic_history <- diagnostic_history
    result$startnode_data <- startnode_data
  }
  return(result)
}
