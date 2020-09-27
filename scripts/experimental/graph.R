library(MASS)
source("./scripts/experimental/geodata.R")

generate_node_data <- function(n, weights = rep.int(1, n), status = rep(0, n), recovery_time = rep.int(-1,n), accuracy = 1000){
  # Status codes
  # S: 0
  # J: 1
  # I: 2
  # R: 3
  sample = geo.sample(n, accuracy)
  x <- sample$x
  y <- sample$y
  y <- max(y) - y
  node_data <- data.frame(weights, status, recovery_time, x, y)
  names(node_data) <- c('weight', 'status', 'recovery_time', 'x', 'y')
  #levels(node_data$status) <- c(0, 2, 3, 1)
  return(node_data)
}

generate_simple_node_data <- function(n, weights=rep.int(1,n), accuracy = 1000) {
  sample = geo.sample(n, accuracy)
  x <- sample$x
  y <- sample$y
  y <- max(y) - y
  node_data <- data.frame(weights, x, y)
  names(node_data) <- c('weight', 'x', 'y')
  return(node_data)
}


generate_empty_graph <- function(n){
  graph <- list()
  for (i in 1:n){
    graph[[i]] <-  vector()
  }
  return(graph)
}


connect <- function(node_data, node1, nodes, alpha = 0.5, lambda = 1){
  w <- node_data$weight
  x <- node_data$x
  y <- node_data$y
  p <- runif(length(nodes))   # uniform sample from [0,1]
  prob <- -expm1(-lambda * w[node1] * w[nodes] / ((x[node1]-x[nodes])**2 + (y[node1]-y[nodes])**2)**alpha)
  # prob <- x- expm1(-lambda / ((x[node1]-x[nodes])**2 + (y[node1]-y[nodes])**2)**alpha)
  return(p < prob)
}






plotgraph <- function(graph, node_data, axes = FALSE, edges=TRUE, dotsize = 1) {
  #split data
  xinf <- node_data[which(node_data$status==2),]$x
  yinf <- node_data[which(node_data$status==2),]$y
  xsus <- node_data[which(node_data$status==0),]$x
  ysus <- node_data[which(node_data$status==0),]$y
  xrec <- node_data[which(node_data$status==3),]$x
  yrec <- node_data[which(node_data$status==3),]$y
  
  x_max <- max(node_data$x)
  x_min <- min(node_data$x)
  x_lims <- c(x_min, x_max)
  y_max <- max(node_data$y)
  y_min <- min(node_data$y)
  y_lims <- c(y_min, y_max)
  #plot data separately per color
  plot(xinf,yinf, pch = 21, col = "black", cex = dotsize, bg = 'red', xlim = x_lims, ylim = y_lims,axes=axes,xlab='',ylab='', asp=1)
  par(new=TRUE)
  plot(xsus,ysus, pch = 21, col = "black", cex = dotsize, bg = 'blue', xlim = x_lims, ylim = y_lims,axes=axes,xlab='',ylab='', asp=1)
  par(new=TRUE)
  plot(xrec,yrec, pch = 21, col = 'black', cex = dotsize, bg = "green", xlim = x_lims, ylim = y_lims,axes=axes,xlab='',ylab='', asp=1)
 
  if (edges){   #connect contacting points
    for (main_node in 1:nrow(node_data)){
      neighbors <- graph[[main_node]]
      
      nodes_to_connect <- neighbors[which(neighbors>main_node)]  # select higher to prevent double-counting
      x_to <- node_data$x[nodes_to_connect]
      y_to <- node_data$y[nodes_to_connect]
      
      if (length(x_to) > 0){
        segments(node_data$x[main_node], node_data$y[main_node], x_to, y_to)
      }
    }
  }
}






node_distance <- function(node_data, node1, node2){
  x <- node_data$x
  y <- node_data$y
  return( ((x[node1]-x[node2])^2 + (y[node1]-y[node2])^2)^0.5 )
}



diagnostics <- function(graph, node_data, fit=FALSE){
  n = length(graph)
  distances = vector()
  edges_per_node = vector(length=n)

  pb <- progress_bar$new(total = n, format=" Diagnosing [:bar] :percent")
  pb$tick(0)
  for (main_node in 1:n){
    neighbors <- graph[[main_node]]
    edges_per_node[main_node] = length(neighbors)

    reduced_neighbors = neighbors[which(neighbors>main_node)]  # select higher to prevent double-counting
    neighbor_distances = node_distance(node_data, main_node, reduced_neighbors)
    distances <- c(distances, neighbor_distances)
    pb$tick()
    
  }
  display_diagnostics(edges_per_node, distances, fit)
}



sample_diagnostics <- function(graph, node_data, fraction, fit=FALSE){
  n = length(graph)
  n_sample <- as.integer(round(n*fraction))
  distances = vector()
  edges_per_node = vector(length=n_sample)
  
  sampled_nodes = sample(1:n, n_sample)
  
  pb <- progress_bar$new(total = n_sample, format=" Diagnosing [:bar] :percent")
  pb$tick(0)

  for (main_node in sampled_nodes){
    neighbors <- graph[[main_node]]
    edges_per_node[main_node] = length(neighbors)
    
    reduced_neighbors = neighbors[which(neighbors>main_node)]  # select higher to prevent double-counting
    neighbor_distances = node_distance(node_data, main_node, reduced_neighbors)
    distances <- c(distances, neighbor_distances)
    pb$tick()
    
    
  }
  display_diagnostics(edges_per_node, distances, fit)
}








display_diagnostics <- function(edges_per_node, distances, fit=FALSE){
  
  total_edges <- as.integer(round(sum(edges_per_node) / 2))  # edges are corrected for double-counting
  
  
  average_edges_per_node <- total_edges / n
  average_edges_connected_to_node <- average_edges_per_node * 2 # double counting is desired in this case
  average_distance <- mean(distances)
  
  # Remove 0 connected edges
  edges_per_node_filtered <- Filter(function(y) {y!=0}, edges_per_node)
  
  print('--- Graph diagnostics ---')
  print(sprintf('Nodes: %d', n))
  print(sprintf('Edges: %d', total_edges))
  print(sprintf('Average edges connected to node: %.2f', average_edges_connected_to_node))
  print(sprintf('Average distance between connected nodes: %.2f', average_distance))
  print(sprintf("Isolated nodes: %d", length(edges_per_node)-length(edges_per_node_filtered)))
  print('See plots for histograms of edges and distances')

  par(mfrow = c(1,2))
  hist(edges_per_node_filtered, main = 'Edges connected to a node', xlab = "edges connected to node", probability=fit)
  # if (fit){
  #   fitparams = fitdistr(edges_per_node_filtered, "poisson")
  #   xas = 1:max(edges_per_node)
  #   lines(xas, dpois(xas, fitparams$estimate))
  #   print('Poisson parameters for #edges:')
  #   print(fitparams$estimate['lambda'])
  # }
  hist(distances, main = 'Distances between connected nodes', probability=fit)
  # if (fit){
  #   fitparams = fitdistr(distances, "exponential")
  #   xas = seq(0, max(distances), l=1000)
  #   lines(xas, dexp(xas, fitparams$estimate))
  #   print(fitparams$estimate)
  #   print(sprintf('Exponential parameter for distances: %.2f', fitparams$estimate))
  # }

}



avg_edges <- function(graph, sample = FALSE, sample_ratio = 1){
  n = length(graph)
  total_edges = 0
  if (!sample){
    for (main_node in 1:n){
      neighbors <- graph[[main_node]]
      total_edges = total_edges + length(neighbors)
    }
    
  }
  else{
    n_sample <- as.integer(round(n*sample_ratio))
    sampled_nodes = sample(1:n, n_sample)
    
    for (main_node in sampled_nodes){
      neighbors <- graph[[main_node]]
      total_edges = total_edges +  length(neighbors)
    }
    total_edges = total_edges/sample_ratio
  }
  return(total_edges/n)
}


