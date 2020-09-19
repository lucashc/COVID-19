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


make_edge <- function(node1, node2){
  graph[[node1]] = c(graph[[node1]], node2)
  graph[[node2]] = c(graph[[node2]], node1)
}


plotgraph <- function(node_data,axbool = FALSE, dotsize = 1) {
  #split data
  xinf <- node_data[which(node_data$status=='I'),]$x
  yinf <- node_data[which(node_data$status=='I'),]$y
  xsus <- node_data[which(node_data$status=='S'),]$x
  ysus <- node_data[which(node_data$status=='S'),]$y
  xrec <- node_data[which(node_data$status=='R'),]$x
  yrec <- node_data[which(node_data$status=='R'),]$y
  xded <- node_data[which(node_data$status=='D'),]$x
  yded <- node_data[which(node_data$status=='D'),]$y
  #plot data separately per color
  plot(xinf,yinf, pch = 21, col = "black", cex = dotsize, bg = 'red', xlim = c(0,10), ylim = c(0,10),axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xsus,ysus, pch = 21, col = "black", cex = dotsize, bg = 'blue', xlim = c(0,10), ylim = c(0,10),axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xrec,yrec, pch = 21, col = 'black', cex = dotsize, bg = "green", xlim = c(0,10), ylim = c(0,10),axes=axbool,xlab='',ylab='')
  par(new=TRUE)
  plot(xded,yded, pch = 4, col = 'red', cex = dotsize, xlab='',ylab='',axes=FALSE, xlim = c(0,10), ylim = c(0,10))
  #connect contacting points
  for (main_node in length(node_data)){
    neighbors = graph[main_node]
    neighbor_amount = length(neighbors)
    if (neighbor_amount == 0){
      next
    }
    for (neighbor_node in neighbors){
      to_x = vector()
      to_y = vector()
      i = 1
      if (neighbor_node > main_node){
        to_x = c(to_x, node_data$x[neighbor_node])
        to_y = c(to_y, node_data$y[neighbor_node])
      }
      segments(node_data$x[main_node], node_data$y[main_node], to_x, to_y)
    }
  }
}


n = 20
node_data <- generate_node_data(n)
graph <- generate_empty_graph(n)
make_edge(1,2)
make_edge(2,3)
make_edge(2,4)
make_edge(4,5)
make_edge(5,6)
make_edge(6,7)
make_edge(6,8)
plotgraph(node_data)
