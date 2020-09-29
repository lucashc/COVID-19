source('./scripts/RGG/graph.R')
library(bench)

n <- 1000
#node_data <- generate_node_data(n)


bench_func_connect <- function(vec){
  for (i in 1:n) {
    connect(i, vec)
  }
}

bench_func_make <- function(graph) {
  for (sick in 1:5) {
    graph[[sick]] <- susceptible[connect(sick, susceptible, alpha, lambda)]
  }
}

bench::mark(
  {vec <- 1:n
  bench_func_connect(vec)}
)
