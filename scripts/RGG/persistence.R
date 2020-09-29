save_result <- function(result, prefix="result", suffix=Sys.time()) {
  filename <- paste("./history/", prefix, " ", suffix, ".Rdata", sep="")
  save(result, file=filename)
}

load_result <- function(name="result") {
  filename <- paste("./history/", name, ".Rdata", sep="")
  load(filename)
  return(result)
}