library(dscrutils)
dscout = dscquery(dsc.outdir = "normal_means", 
                  targets = c("simulate.true_pi0", "simulate.true_a", "simulate.true_mu", 
                              "eb.prior", "eb.fix_mu", "eb.g_pi0", "eb.g_a", "eb.g_mu", 
                              "eb.loglik", "score.RMSE"))

View(dscout)
