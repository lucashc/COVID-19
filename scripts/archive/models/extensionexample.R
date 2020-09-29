# ergm specifications
erg.networksize <- 1000000
erg.formation <- ~edges
erg.target.stats <- c(erg.networksize*2)
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

source("scripts/models/submodules/simplerecovery.R")
source("scripts/models/submodules/simpleprevalance.R")

preval = simpelprevalance
recov = simplerecovery

lockdown <- function(dat, at) {
  if (at == 2) {return(dat)}
  if (dat$epi$i.num[at-1] > 0.05*erg.networksize) {
    dat$param$inf.prob = 0.001
  } else {
    dat$param$inf.prob =  dat$param$inf.prob + 0.0001
  }
  return(dat)
}

simulation.init <- init.net(i.num = 10, r.num = 0)
simulation.param <- param.net(inf.prob = 0.01, act.rate = 10, rec.rate = 0.1)
simulation.control <- control.net(type = NULL, nsteps = 400, nsims = 2, infection.FUN = infection.net, prevalence.FUN = preval, recovery.FUN = recov, lockdown.FUN = lockdown)


simulation.results <- function(sim) {
  print(sim)
  plot(sim)
}