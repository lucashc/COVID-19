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
  for (i in 1:as.integer(n/2)) {
    for (j in as.integer(n/2):n) {
      graph <- make_edge(graph, i, j)
    }
  }
}

mark(
  {graph <- generate_empty_graph(n)
  bench_func_make(graph)}
)