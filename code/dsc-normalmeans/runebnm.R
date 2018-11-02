#' This function is a wrapper for the ebnm function
#' It takes in data, x and s, as usual
#' The prior is either 1 (for "point_normal") or 2 (for "point_laplace")
#' If fix_mu_in == 1, then mu is fixed at 0

library(ebnm)
ebnm.wrapper = function(x, s, prior_in, fix_mu_in) {
  if (prior_in == 1) {
    prior = "point_normal"
  } else if (prior_in == 2) {
    prior = "point_laplace"
  }
  if (ix_mu_in == 1) {
    res = ebnm(x, s, prior, g = list(mu = 0), fix_mu = T)
  } else {
    res = ebnm(x, s, prior, g = NULL, fix_mu = F)
  }
  out = list(prior = prior, fix_mu = fix_mu_in, pm = res$result$PosteriorMean, fitted_g = res$fitted_g, loglik = res$loglik)
  return(out)
}

ebnm_data = ebnm.wrapper(x, s, prior_in, fix_mu_in)
