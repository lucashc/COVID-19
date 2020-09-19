source("./scripts/experimental/geodata.R")

generate_node_data <- function(n, weights = rep.int(1, n), status = rep('S', n), recovery_time = rep.int(-1,n), accuracy = 1000){
  sample = geo.sample(n, accuracy)
  x <- sample$x
  y <- sample$y
  node_data <- data.frame(weights, status, recovery_time, x, y)
  names(node_data) <- c('weight', 'status', 'recovery_time', 'x', 'y')
  levels(node_data$status) <- c('S', 'I', 'D', 'R')
  return(node_data)
}



generate_empty_graph <- function(n){
  graph = list()
  for (i in 1:n){
    graph[[i]] <-  vector()
  }
  return(graph)
}


distance_c <- function(node1, node2){
  x = node_data$x
  y = node_data$y
  return((x[node1]-x[node2])**2 + (y[node1]-y[node2])**2)**0.5
}



connect <- function(node1, node2, alpha = 1, lambda = 1){
  w = node_data$weight
  p <- runif(1, 0, 1)[1]
  prob <- 1 - exp(-lambda*w[node1]*w[node2]/(distance_c(node1, node2))^alpha)
  return(p < prob)
}


make_edge <- function(graph, node1, node2){
  graph[[node1]] = c(graph[[node1]], node2)
  graph[[node2]] = c(graph[[node2]], node1)
  return(graph)
}


plotgraph <- function(node_data,axbool = FALSE, dotsize = 1) {
  #split data
  xinf <- node_data[which(node_data$status=='I'),]$x
  print(xinf)
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
  plot(xinf,yinf, pch = 21, col = "black", cex = dotsize, bg = 'red', xlim = x_lims, ylim = y_lims,axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xsus,ysus, pch = 21, col = "black", cex = dotsize, bg = 'blue', xlim = x_lims, ylim = y_lims,axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xrec,yrec, pch = 21, col = 'black', cex = dotsize, bg = "green", xlim = x_lims, ylim = y_lims,axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xded,yded, pch = 4, col = 'red', cex = dotsize, xlab='',ylab='',axes=axbool, xlim = x_lims, ylim = y_lims)
  
  if (TRUE){
  #connect contacting points
  for (main_node in 1:length(node_data)){
    neighbors = graph[[main_node]]
    neighbor_amount = length(neighbors)
    if (neighbor_amount == 0){
      next
    }
    
    for (neighbor_node in neighbors){
      print(neighbors)
      x_to = vector()
      y_to = vector()

      if (neighbor_node > main_node){
        x_to= c(x_to, node_data$x[neighbor_node])
        y_to = c(y_to, node_data$y[neighbor_node])
        print(x_to)
        print(y_to)
      }
      if (length(x_to) > 0){
        segments(node_data$x[main_node], node_data$y[main_node], x_to, y_to)
      }
    }
  }
  }
}


n = 10
node_data <- generate_node_data(n)
node_data$status[2] = 'I'
node_data$status[3] = 'R'
node_data$status[4] = 'D'
graph <- generate_empty_graph(n)
graph <- make_edge(graph, 1,2)
graph <- make_edge(graph, 2,3)
graph <- make_edge(graph, 2,4)
graph <- make_edge(graph, 4,5)
graph <- make_edge(graph, 5,6)
graph <- make_edge(graph, 6,7)
graph <- make_edge(graph, 6,8)
graph <- make_edge(graph, 9,10)

print(graph)
plotgraph(node_data, TRUE)
print(node_data)
