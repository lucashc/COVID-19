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