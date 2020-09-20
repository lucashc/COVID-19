source('./scripts/experimental/graph.R')
library(bench)

n <- 100
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

mark(
  {graph <- generate_empty_graph(n)
  bench_func_make(graph)}
)
