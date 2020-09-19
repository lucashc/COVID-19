source('./scripts/experimental/graph.R')
library(bench)

n <- 100
node_data <- generate_node_data(n)

bench_func <- function(){
  data <- matrix(0, n, n)
  for (i in 1:n) {
    for (j in 1:n) {
      data[i, j] <- connect(i, j)
    }
  }
  return(data)
}


mark(
  bench_func()
)