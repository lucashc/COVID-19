library(raster)
library(spatstat)

geo.load <- function(accuracy=1000) {
  # Returns density as matrix
  if (accuracy == 250) {
    X<- raster('popdens250.tif')
  }else{
    X <- raster('popdens.tif')
  }
  X[is.na(X)] <- 0
  return(as.matrix(X))
}

geo.rpoints <- function(d, n=100) {
  return(rpoint(n, as.im(d)))
}

geo.verify_data <- function(d, p) {
  image(t(apply(d, 2, rev)))
  points(p$x/684, 1-p$y/808, pch=20, cex=0.5, col="green")
}

geo.sample <- function(n=1000, accuracy=1000, verify=FALSE) {
  d <- geo.load(accuracy)
  p <- geo.rpoints(d, n)
  if (verify) {
    geo.verify_data(d, p)
  }
  rm(d)
  return(p)
}

geo.getMask <- function() {
  X <- raster('germany.tif')
  return(as.matrix(X))
}
