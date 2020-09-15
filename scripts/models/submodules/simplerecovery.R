simplerecovery <- function(dat, at) {
  
  # Variables ---------------------------------------------------------------
  active <- get_attr(dat, "active")
  status <- get_attr(dat, "status")
  infTime <- get_attr(dat, "infTime")
  recovState <- "r"
  
  rec.rate <- get_param(dat, "rec.rate")
  
  nRecov <- 0
  idsElig <- which(active == 1 & status == "i")
  nElig <- length(idsElig)
  
  
  # Time-Varying Recovery Rate ----------------------------------------------
  infDur <- at - infTime[active == 1 & status == "i"]
  infDur[infDur == 0] <- 1
  lrec.rate <- length(rec.rate)
  if (lrec.rate == 1) {
    ratesElig <- rec.rate
  } else {
    ratesElig <- ifelse(infDur <= lrec.rate, rec.rate[infDur], rec.rate[lrec.rate])
  }
  
  
  # Process -----------------------------------------------------------------
  if (nElig > 0) {
    vecRecov <- which(rbinom(nElig, 1, ratesElig) == 1)
    if (length(vecRecov) > 0) {
      idsRecov <- idsElig[vecRecov]
      nRecov <- length(idsRecov)
      status[idsRecov] <- recovState
    }
  }
  dat <- set_attr(dat, "status", status)
  
  # Output ------------------------------------------------------------------
  outName <- "ir.flow"
  dat <- set_epi(dat, outName, at, nRecov)
  
  return(dat)
}