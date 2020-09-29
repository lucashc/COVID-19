simpelprevalance <- function(dat, at) {
  
  active <- get_attr(dat, "active")
  type <- get_control(dat, "type")
  groups <- get_param(dat, "groups")
  
  # Subset attr to active == 1
  l <- lapply(1:length(dat$attr), function(x) dat$attr[[x]][active == 1])
  names(l) <- names(dat$attr)
  l$active <- l$infTime <- NULL
  
  status <- l$status
  
  ## Subsetting for epi.by control
  eb <- !is.null(dat$control$epi.by)
  if (eb == TRUE) {
    ebn <- get_control(dat, "epi.by")
    ebv <- dat$temp$epi.by.vals
    ebun <- paste0(".", ebn, ebv)
    assign(ebn, l[[ebn]])
  }
  
  if (at == 1) {
    dat$epi <- list()
  }
  
  
  dat <- set_epi(dat, "s.num", at, sum(status == "s"))
  if (eb == TRUE) {
    for (i in 1:length(ebun)) {
      ebn.temp <- paste0("s.num", ebun[i])
      dat <- set_epi(dat, ebn.temp, at, sum(status == "s" &
                                              get(ebn) == ebv[i]))
    }
  }
  
  dat <- set_epi(dat, "i.num", at, sum(status == "i"))
  if (eb == TRUE) {
    for (i in 1:length(ebun)) {
      ebn.temp <- paste0("i.num", ebun[i])
      dat <- set_epi(dat, ebn.temp, at, sum(status == "i" &
                                              get(ebn) == ebv[i]))
    }
  }
  
  dat <- set_epi(dat, "r.num", at, sum(status == "r"))
  if (eb == TRUE) {
    for (i in 1:length(ebun)) {
      ebn.temp <- paste0("r.num", ebun[i])
      dat <- set_epi(dat, ebn.temp, at, sum(status == "r" &
                                              get(ebn) == ebv[i]))
    }
  }
  
  dat <- set_epi(dat, "num", at, length(status))
  if (eb == TRUE) {
    for (i in 1:length(ebun)) {
      ebn.temp <- paste0("num", ebun[i])
      dat <- set_epi(dat, ebn.temp, at, sum(get(ebn) == ebv[i]))
    }
  }
  
  return(dat)
}