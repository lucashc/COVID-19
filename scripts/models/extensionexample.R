# ergm specifications
erg.networksize <- 100
erg.formation <- ~edges
erg.target.stats <- c(200)
erg.coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 80)
erg.initialise <- function (nw) {
  return(nw)
}

# diagnoses
diagnose.nsims <- 10
diagnose.nsteps <- 100

diagnose.results <- function(dx) {
  print("run")
  print(dx)
  plot(dx)
}

# simulation


recov <- function(dat, at) {
  
  
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

preval <- function(dat, at) {
  
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


lockdown <- function(dat, at) {
  if (at == 100) {
    dat$param$inf.prob = 0.0001
  }
  return(dat)
}

simulation.init <- init.net(i.num = 10, r.num = 0)
simulation.param <- param.net(inf.prob = 0.001, act.rate = 10, rec.rate = 0.01)
simulation.control <- control.net(type = NULL, nsteps = 200, nsims = 10, infection.FUN = infection.net, prevalence.FUN = preval, recovery.FUN = recov, lockdown.FUN = lockdown)


simulation.results <- function(sim) {
  print(sim)
  plot(sim)
}