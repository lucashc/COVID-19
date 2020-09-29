save_result <- function(result, prefix="result", suffix=Sys.time()) {
  filename <- paste("./history/", prefix, " ", suffix, ".Rdata", sep="")
  save(result, file=filename)
}