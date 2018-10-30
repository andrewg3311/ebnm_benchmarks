library(dscrutils)
library(dplyr)
library(tidyr)
library(ggplot2)

dscout = dscquery(dsc.outdir = "normal_means", 
                  targets = c("simulate.true_pi0", "simulate.true_a", "simulate.true_mu", 
                              "eb.prior", "eb.fix_mu", "eb.g_pi0", "eb.g_a", "eb.g_mu", 
                              "eb.loglik", "score.RMSE"))

dscout_wide = dscout %>% spread(score, score.RMSE)
View(dscout_wide)

labels_pi0 = character(length(unique(dscout_wide$simulate.true_pi0)))
for (i in 1:length(labels_pi0)) {
  labels_pi0[i] = paste("pi0 = ", unique(dscout_wide$simulate.true_pi0)[i], sep = "")
  names(labels_pi0)[i] = unique(dscout_wide$simulate.true_pi0)[i]
}
labels_a = character(length(unique(dscout_wide$simulate.true_a)))
for (i in 1:length(labels_a)) {
  labels_a[i] = paste("a = ", unique(dscout_wide$simulate.true_a)[i], sep = "")
  names(labels_a)[i] = unique(dscout_wide$simulate.true_a)[i]
}
labels_fix_mu = character(length(unique(dscout_wide$eb.fix_mu)))
for (i in 1:length(labels_fix_mu)) {
  labels_fix_mu[i] = paste("fix_mu = ", unique(dscout_wide$eb.fix_mu)[i], sep = "")
  names(labels_fix_mu)[i] = unique(dscout_wide$eb.fix_mu)[i]
}

ggplot(dscout_wide, aes(x = factor(simulate.true_a), y = eb.g_a)) +
  geom_boxplot() + facet_grid(eb.fix_mu ~ simulate.true_pi0, labeller = labeller(simulate.true_pi0 = labels_pi0, eb.fix_mu = labels_fix_mu))


ggplot(dscout_wide, aes(x = factor(simulate.true_pi0), y = eb.g_pi0)) +
  geom_boxplot() + facet_grid(eb.fix_mu ~ simulate.true_a, labeller = labeller(simulate.true_a = labels_a, eb.fix_mu = labels_fix_mu))


ggplot(filter(dscout_wide, eb.fix_mu == 1), aes(x = factor(simulate.true_mu), y = eb.g_mu)) +
  geom_boxplot() + facet_grid(simulate.true_pi0 ~ simulate.true_a, labeller = labeller(simulate.true_a = labels_a, simulate.true_a = labels_pi0))
