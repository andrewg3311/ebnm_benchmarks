library(ebnm)
ebnm.wrapper = function(input, args) {
  if (args$prior_in == 1) {
    prior = "point_normal"
  } else if (args$prior_in == 2) {
    prior = "point_laplace"
  }
  if (args$fix_mu_in == 1) {
    res = ebnm(input$x, input$s, prior, g = list(mu = 0), fix_mu = T)
  } else {
    res = ebnm(input$x, input$s, prior, g = NULL, fix_mu = F)
  }
  out = list(prior = prior, fix_mu = args$fix_mu_in, pm = res$result$PosteriorMean, fitted_g = res$fitted_g, loglik = res$loglik)
  return(out)
}

ebnm_data = ebnm.wrapper(data$input, args)
