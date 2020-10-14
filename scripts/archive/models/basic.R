# ergm specifications
erg.networksize <- as.integer(1e4)
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
simulation.init <- init.net(i.num = 10, r.num = 0)
simulation.param <- param.net(inf.prob = 0.02, act.rate = 10, rec.rate = 0.01)
simulation.control <- control.net(type = "SIR", nsteps = 100, nsims = 10)

simulation.results <- function(sim) {
  print(sim)
  summary(sim, at = 100)
  plot(sim)
  plot(sim, y = c("si.flow", "ir.flow"), legend=TRUE)
}
