source('./scripts/experimental/graph.R')
library(bench)

n <- 100
node_data <- generate_node_data(n)


bench_func <- function(vec){
  for (i in 1:n) {
    connect(i, vec)
  }
}


mark(
  {vec <- 1:100
  bench_func(vec)}
)