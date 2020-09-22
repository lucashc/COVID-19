library(MASS)
source("./scripts/experimental/geodata.R")

generate_node_data <- function(n, weights = rep.int(1, n), status = rep('S', n), recovery_time = rep.int(-1,n), accuracy = 1000){
  sample = geo.sample(n, accuracy)
  x <- sample$x
  y <- sample$y
  y <- max(y) - y
  node_data <- data.frame(weights, status, recovery_time, x, y)
  names(node_data) <- c('weight', 'status', 'recovery_time', 'x', 'y')
  levels(node_data$status) <- c('S', 'I', 'R', 'J')
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
  xinf <- node_data[which(node_data$status=='I'),]$x
  yinf <- node_data[which(node_data$status=='I'),]$y
  xsus <- node_data[which(node_data$status=='S'),]$x
  ysus <- node_data[which(node_data$status=='S'),]$y
  xrec <- node_data[which(node_data$status=='R'),]$x
  yrec <- node_data[which(node_data$status=='R'),]$y
  
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


# distribution functions for distance fitting (must be in global scope)

dinvexp <- function(x,lambda,alpha){
  return(-expm1(-lambda/x^alpha))
}

pinvexp <- function(q,lambda,alpha){
  # this function only exists because fitdistrplus complains if it doesn't
  # even though it is not used. There is no closed form PDF for this distribution
  return(q)
}


diagnostics <- function(graph, node_data, fit=FALSE){
  n = length(graph)
  edges_per_node = vector(length = n)
  
  for (main_node in 1:n){
    neighbors <- graph[[main_node]]
    edges_per_node[main_node] <- length(neighbors)
  }
  
  total_edges <- as.integer(round(sum(edges_per_node) / 2))  # edges are corrected for double-counting  
  distances = vector(length = total_edges)
  edge_nr = 1
  for (main_node in 1:n){
    neighbors <- graph[[main_node]]
    reduced_neighbors = neighbors[which(neighbors>main_node)]  # select higher to prevent double-counting
    k = length(reduced_neighbors)
    # print("red_n")
    # print(reduced_neighbors)

    if (k != 0){
      neighbor_distances = node_distance(node_data, main_node, reduced_neighbors)
      # print("k, n_d")
      # print(k)
      # print(neighbor_distances)
      distances[edge_nr:(edge_nr+k-1)] <- neighbor_distances
      edge_nr = edge_nr + k
    }

  }
  

  
  average_edges_per_node = total_edges/n  # edges are corrected for double-counting
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
  
  

  # 
  # if (fit){
  #   # the distance distr will be called "invexp"
  #   
  # 
  #   
  #   # fitparams = fitdist(distances, "invexp", start = list(lambda = 1, alpha = 1), method="mle") #fitdistr(distances, "exponential")
  #   fitparams = fitdistr(distances, "weibull")
  #   xas = seq(0, max(distances), l=1000)
  #   print(fitparams)
  #   lines(xas, dweibull(xas, fitparams$estimate))
  #   plot(xas,  dweibull(xas, fitparams$estimate))
  #   print(fitparams$estimate)
  #   print(sprintf('Exponential parameter for distances: %.2f', fitparams$estimate))
  # }

}
