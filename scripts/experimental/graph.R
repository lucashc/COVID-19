source("./scripts/experimental/geodata.R")

generate_node_data <- function(n, weights = rep.int(1, n), status = rep('S', n), recovery_time = rep.int(-1,n), death_time= rep.int(-1,n), accuracy = 1000){
  sample = geo.sample(n, accuracy)
  x <- sample$x
  y <- sample$y
  y <- max(y) - y
  node_data <- data.frame(weights, status, recovery_time, death_time, x, y)
  names(node_data) <- c('weight', 'status', 'recovery_time', 'death_time', 'x', 'y')
  levels(node_data$status) <- c('S', 'I', 'D', 'R', 'J')
  return(node_data)
}



generate_empty_graph <- function(n){
  graph = list()
  for (i in 1:n){
    graph[[i]] <-  vector()
  }
  return(graph)
}



connect <- function(node1, nodes, alpha = 0.5, lambda = 1){
  w <- node_data$weight
  x <- node_data$x
  y <- node_data$y
  p <- runif(length(nodes))   # uniform sample from [0,1]
  prob <- 1 - exp(-lambda * w[node1] * w[nodes] / ((x[node1]-x[nodes])**2 + (y[node1]-y[nodes])**2)**alpha)
  return(p < prob)
}



make_edge <- function(graph, node1, node2){
  graph[[node1]] = c(graph[[node1]], node2)
  graph[[node2]] = c(graph[[node2]], node1)
  return(graph)
}


plotgraph <- function(node_data, axes = FALSE, edges=TRUE, dotsize = 1) {
  #split data
  xinf <- node_data[which(node_data$status=='I'),]$x
  yinf <- node_data[which(node_data$status=='I'),]$y
  xsus <- node_data[which(node_data$status=='S'),]$x
  ysus <- node_data[which(node_data$status=='S'),]$y
  xrec <- node_data[which(node_data$status=='R'),]$x
  yrec <- node_data[which(node_data$status=='R'),]$y
  xded <- node_data[which(node_data$status=='D'),]$x
  yded <- node_data[which(node_data$status=='D'),]$y
  
  x_max = max(node_data$x)
  x_min = min(node_data$x)
  x_lims = c(x_min, x_max)
  y_max = max(node_data$y)
  y_min = min(node_data$y)
  y_lims = c(y_min, y_max)
  #plot data separately per color
  plot(xinf,yinf, pch = 21, col = "black", cex = dotsize, bg = 'red', xlim = x_lims, ylim = y_lims,axes=axes,xlab='',ylab='', asp=1)
  par(new=TRUE)
  plot(xsus,ysus, pch = 21, col = "black", cex = dotsize, bg = 'blue', xlim = x_lims, ylim = y_lims,axes=axes,xlab='',ylab='', asp=1)
  par(new=TRUE)
  plot(xrec,yrec, pch = 21, col = 'black', cex = dotsize, bg = "green", xlim = x_lims, ylim = y_lims,axes=axes,xlab='',ylab='', asp=1)
  par(new=TRUE)
  plot(xded,yded, pch = 4, col = 'red', cex = dotsize, xlab='',ylab='',axes=axes, xlim = x_lims, ylim = y_lims, asp=1)
  
  if (edges){   #connect contacting points
    for (main_node in 1:nrow(node_data)){
      neighbors = graph[[main_node]]
      
      x_to = node_data$x[neighbors]
      y_to = node_data$y[neighbors]
      
      if (length(x_to) > 0){
        segments(node_data$x[main_node], node_data$y[main_node], x_to, y_to)
      }
    }
  }
}

