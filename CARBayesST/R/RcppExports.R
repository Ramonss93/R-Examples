# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

linpredcompute <- function(X, nsites, p, beta, offset) {
    .Call('CARBayesST_linpredcompute', PACKAGE = 'CARBayesST', X, nsites, p, beta, offset)
}

quadform <- function(Wtriplet, Wtripletsum, n_triplet, nsites, phi, theta, rho) {
    .Call('CARBayesST_quadform', PACKAGE = 'CARBayesST', Wtriplet, Wtripletsum, n_triplet, nsites, phi, theta, rho)
}

poissoncarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, phi, tau2, y, phi_tune, rho, offset, ntime, mult_offset, missind) {
    .Call('CARBayesST_poissoncarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, phi, tau2, y, phi_tune, rho, offset, ntime, mult_offset, missind)
}

poissonindepupdate <- function(nsites, theta, tau2, y, theta_tune, offset, missind) {
    .Call('CARBayesST_poissonindepupdate', PACKAGE = 'CARBayesST', nsites, theta, tau2, y, theta_tune, offset, missind)
}

poissonbetaupdate <- function(X, nsites, p, beta, proposal, offset, y, prior_meanbeta, prior_varbeta, missind) {
    .Call('CARBayesST_poissonbetaupdate', PACKAGE = 'CARBayesST', X, nsites, p, beta, proposal, offset, y, prior_meanbeta, prior_varbeta, missind)
}

binomialbetaupdate <- function(X, nsites, p, beta, proposal, offset, y, failures, prior_meanbeta, prior_varbeta, missind) {
    .Call('CARBayesST_binomialbetaupdate', PACKAGE = 'CARBayesST', X, nsites, p, beta, proposal, offset, y, failures, prior_meanbeta, prior_varbeta, missind)
}

binomialindepupdate <- function(nsites, theta, tau2, y, failures, theta_tune, offset, missind) {
    .Call('CARBayesST_binomialindepupdate', PACKAGE = 'CARBayesST', nsites, theta, tau2, y, failures, theta_tune, offset, missind)
}

binomialcarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, phi, tau2, y, failures, phi_tune, rho, offset, ntime, mult_offset, missind) {
    .Call('CARBayesST_binomialcarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, phi, tau2, y, failures, phi_tune, rho, offset, ntime, mult_offset, missind)
}

gaussiancarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, phi, tau2, nu2, offset, rho, ntime) {
    .Call('CARBayesST_gaussiancarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, phi, tau2, nu2, offset, rho, ntime)
}

poissonarcarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, tau2, gamma, rho, ymat, phi_tune, offset, denoffset, missind) {
    .Call('CARBayesST_poissonarcarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, tau2, gamma, rho, ymat, phi_tune, offset, denoffset, missind)
}

gammaquadformcompute <- function(Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho) {
    .Call('CARBayesST_gammaquadformcompute', PACKAGE = 'CARBayesST', Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho)
}

tauquadformcompute <- function(Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho, gamma) {
    .Call('CARBayesST_tauquadformcompute', PACKAGE = 'CARBayesST', Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho, gamma)
}

binomialarcarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, tau2, gamma, rho, ymat, failuresmat, phi_tune, offset, denoffset, missind) {
    .Call('CARBayesST_binomialarcarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, tau2, gamma, rho, ymat, failuresmat, phi_tune, offset, denoffset, missind)
}

gaussianarcarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, tau2, nu2, gamma, rho, offset, denoffset, missind) {
    .Call('CARBayesST_gaussianarcarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, tau2, nu2, gamma, rho, offset, denoffset, missind)
}

qform <- function(Qtrip, phi) {
    .Call('CARBayesST_qform', PACKAGE = 'CARBayesST', Qtrip, phi)
}

qform_asym <- function(Qtrip, phi1, phi2) {
    .Call('CARBayesST_qform_asym', PACKAGE = 'CARBayesST', Qtrip, phi1, phi2)
}

qformSPACETIME <- function(Qtrip, phi, ntime, nsite) {
    .Call('CARBayesST_qformSPACETIME', PACKAGE = 'CARBayesST', Qtrip, phi, ntime, nsite)
}

SPTICARphiBinomial <- function(W, nsites, ntimes, phi, nneighbours, tau, y, alpha, XB, phiVarb_tune, trials) {
    .Call('CARBayesST_SPTICARphiBinomial', PACKAGE = 'CARBayesST', W, nsites, ntimes, phi, nneighbours, tau, y, alpha, XB, phiVarb_tune, trials)
}

SPTICARphiGaussian <- function(W, nsites, ntimes, phi, nneighbours, tau, lik_var, y, alpha, XB) {
    .Call('CARBayesST_SPTICARphiGaussian', PACKAGE = 'CARBayesST', W, nsites, ntimes, phi, nneighbours, tau, lik_var, y, alpha, XB)
}

SPTICARphiVarb <- function(W, nsites, ntimes, phiVarb, nneighbours, tau, y, E, phiVarb_tune, alpha, XB) {
    .Call('CARBayesST_SPTICARphiVarb', PACKAGE = 'CARBayesST', W, nsites, ntimes, phiVarb, nneighbours, tau, y, E, phiVarb_tune, alpha, XB)
}

qform_difference_ST <- function(Qtrip, Qtime, phi, nsites) {
    .Call('CARBayesST_qform_difference_ST', PACKAGE = 'CARBayesST', Qtrip, Qtime, phi, nsites)
}

qform_ST <- function(Qspace, Qtime, phi, nsites) {
    .Call('CARBayesST_qform_ST', PACKAGE = 'CARBayesST', Qspace, Qtime, phi, nsites)
}

qform_ST_asym <- function(Qspace, Qtime, phi1, phi2, nsites) {
    .Call('CARBayesST_qform_ST_asym', PACKAGE = 'CARBayesST', Qspace, Qtime, phi1, phi2, nsites)
}

update_Qtime <- function(Qtime, alpha, rowNumberLastDiag) {
    .Call('CARBayesST_update_Qtime', PACKAGE = 'CARBayesST', Qtime, alpha, rowNumberLastDiag)
}

updatetriplets_rho <- function(trips, nsites, rho_old, rho_new, fixedridge) {
    .Call('CARBayesST_updatetriplets_rho', PACKAGE = 'CARBayesST', trips, nsites, rho_old, rho_new, fixedridge)
}

updatetripList2 <- function(trips, vold, vnew, nedges, nsites, block, block_length, rho, fixedridge) {
    .Call('CARBayesST_updatetripList2', PACKAGE = 'CARBayesST', trips, vold, vnew, nedges, nsites, block, block_length, rho, fixedridge)
}

Zupdatesqbin <- function(Z, Offset, Y, delta, lambda, nsites, ntime, G, SS, prioroffset, Gstar, failures) {
    .Call('CARBayesST_Zupdatesqbin', PACKAGE = 'CARBayesST', Z, Offset, Y, delta, lambda, nsites, ntime, G, SS, prioroffset, Gstar, failures)
}

Zupdatesqpoi <- function(Z, Offset, Y, delta, lambda, nsites, ntime, G, SS, prioroffset, Gstar) {
    .Call('CARBayesST_Zupdatesqpoi', PACKAGE = 'CARBayesST', Z, Offset, Y, delta, lambda, nsites, ntime, G, SS, prioroffset, Gstar)
}

Zupdatesqgau <- function(Z, Offset, delta, lambda, nsites, ntime, G, SS, prioroffset, Gstar, nu2) {
    .Call('CARBayesST_Zupdatesqgau', PACKAGE = 'CARBayesST', Z, Offset, delta, lambda, nsites, ntime, G, SS, prioroffset, Gstar, nu2)
}

tau2compute <- function(tau2, temp, tau2_shape, prior_tau2, N) {
    .Call('CARBayesST_tau2compute', PACKAGE = 'CARBayesST', tau2, temp, tau2_shape, prior_tau2, N)
}

rhoquadformcompute <- function(Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho, tau2) {
    .Call('CARBayesST_rhoquadformcompute', PACKAGE = 'CARBayesST', Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho, tau2)
}

binomialsrecarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, rho, ymat, failuresmat, phi_tune, offset, denoffset, tau2) {
    .Call('CARBayesST_binomialsrecarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, rho, ymat, failuresmat, phi_tune, offset, denoffset, tau2)
}

poissonsrecarupdate <- function(Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, rho, ymat, phi_tune, offset, denoffset, tau2) {
    .Call('CARBayesST_poissonsrecarupdate', PACKAGE = 'CARBayesST', Wtriplet, Wbegfin, Wtripletsum, nsites, ntime, phi, rho, ymat, phi_tune, offset, denoffset, tau2)
}

tauquadformcompute2 <- function(Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho) {
    .Call('CARBayesST_tauquadformcompute2', PACKAGE = 'CARBayesST', Wtriplet, Wtripletsum, n_triplet, nsites, ntime, phi, rho)
}


