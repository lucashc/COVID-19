library(EpiModel)

source("scripts/local-settings.R")

nw <- network::network.initialize(n = erg.networksize, directed = FALSE)
nw <- erg.initialise(nw)
est <- netest(nw, erg.formation, erg.target.stats, erg.coef.diss)

if (settings.verifyERGM) {
  dx <- netdx(est, nsims = diagnose.nsims, nsteps = diagnose.nsteps)
  diagnose.results(dx)
}

sim <- netsim(est, simulation.param, simulation.init, simulation.control)

simulation.results(sim)

