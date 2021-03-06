library(progress)
library(MASS)
source("./scripts/RGG/geodata.R")

printnq<- function(...){
  print(sprintf(...), quote=FALSE)
}


generate_node_data <- function(n, weights = rep.int(1, n), status = rep(0, n), recovery_time = rep.int(-1,n), accuracy = 1000, sample=NULL){
  # Status codes
  # S: 0  (susceptible)
  # J: 1  (newly infected)
  # I: 2  (infected but not J)
  # R: 3  (recovered)
  if (is.null(sample)) {
    sample = geo.sample(n, accuracy)
  }
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



graph_diagnostics <- function(graph, node_data, groups = c(2,3), fit=FALSE){
  S <- FALSE
  if (0 %in% groups){
    warning("Including susceptible nodes drastically increases compute time", immediate. = TRUE)
    S <- TRUE
  }
  
  if (all(groups == 1)){
    stop("Newly infected nodes do not have edges")
  }
  
  explored = which(node_data$status %in% groups)
  if (length(explored) == 0) {
    diag <- list(edges_per_node = vector(), distances = vector(), average_distance = 0, average_degree = 0)
    class(diag) <- "graph_diagnostics"
    return(diag)
  }
  n = length(explored)
  distances = vector()
  
  edges_per_node = rep(0, n) # vector(length=n)
  if (S){
    pb <- progress_bar$new(total = n, format=" Diagnosing [:bar] :percent")
    pb$tick(0)
  }
  
  
  
  for (i in 1:n){
    main_node = explored[i]
    neighbors <- graph[[main_node]]
    edges_per_node[i] <- edges_per_node[i] + length(neighbors) #+ length(neighbors[which(node_data$status[neighbors] %in% c(2,3))])  # double count edges
    for (neighbor in neighbors){
      index = match(neighbor, explored)
      if (!is.na(index)){
        edges_per_node[index] <- edges_per_node[index] + 1
      }
    }
    reduced_neighbors <- neighbors[which(neighbors>main_node)]  # select higher to prevent double-counting
    neighbor_distances <- node_distance(node_data, main_node, reduced_neighbors)
    distances <- c(distances, neighbor_distances)
    if (S){pb$tick()}
  }
  
  average_degree <- mean(edges_per_node) # double counting is desired in this case
  average_distance <- mean(distances)
  median_degree <- median(edges_per_node)
  median_distance <- median(distances)
  
  diag <- list(edges_per_node = edges_per_node, 
               distances = distances, 
               average_distance = average_distance, 
               average_degree = average_degree, 
               median_degree=median_degree, 
               median_distance = median_distance)
  class(diag) <- "graph_diagnostics"
  
  return(diag)
}



print.graph_diagnostics <- function(diag){
  edges_per_node = diag$edges_per_node
  distances = diag$distances
  average_distance = diag$average_distance
  average_degree = diag$average_degree
  median_degree = diag$median_degree
  median_distance = diag$median_distance
  
  
  total_edges <- as.integer(round(sum(edges_per_node) / 2))  # edges are corrected for double-counting
  # Remove 0 connected edges
  printnq('--- Graph diagnostics ---')
  printnq(sprintf('Explored nodes: %d', length(edges_per_node)))
  
  printnq('Edges: %d', total_edges)
  printnq("Node degree")
  printnq('- Mean: %.2f',average_degree)
  printnq('- Median: %.2f', median_degree)
  printnq('- Std. dev: %.2f', var(edges_per_node)^0.5)
                
  printnq('Distance between connected nodes')
  printnq('- Mean: %.2f', average_distance)
  printnq('- Median: %.2f', median_distance)
  printnq('- Std. dev: %.2f', var(distances)^0.5)
  printnq('-------------------------')
}



fit_diagnostics <- function(diag) {
  
  edges_per_node <- diag$edges_per_node
  edges_minus_outliers <- edges_per_node[which(edges_per_node < quantile(edges_per_node, .99))]
  degree_hist <- hist(edges_minus_outliers, breaks = max(edges_minus_outliers), probability = TRUE)
  degree_hist$probability <- TRUE
  if (degree_hist$counts[1] > degree_hist$counts[2]){
    warning("You probably included newly infected and/or susceptible people in your diagnostics. This causes inaccurate fitting for the node degree.", immediate. = TRUE)
  }
    
  distances = diag$distances
  
  printnq("--- Fit parameters ---")
  par(mfrow = c(1,2))
  hist(edges_minus_outliers, breaks = max(edges_minus_outliers), probability = TRUE, main = 'Node degree', xlab = "degree")
  fitparams <- fitdistr(edges_minus_outliers, "poisson")
  xas <- 1:max(edges_per_node)
  lines(xas, dpois(xas, fitparams$estimate))
  printnq('Poisson parameter for node degree: %.2f', fitparams$estimate)
  
  hist(distances, main = 'Distances between connected nodes', xlab = "distance (km)", probability = TRUE)
  fitparams <- fitdistr(distances, "exponential")
  xas <- seq(0, max(distances), l=1000)
  lines(xas, dexp(xas, fitparams$estimate))
  printnq('Exponential parameter for distances: %.4f', fitparams$estimate)
  printnq('----------------------')
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
      total_edges = total_edges + length(neighbors)
    }
    total_edges = total_edges/sample_ratio
  }
  return(total_edges/n)
}
