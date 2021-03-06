library(workflowr)
library(microbenchmark)
library(dplyr)
library(RColorBrewer)
devtools::load_all("../../ebnm")

# This function simulates data from the ebnm (point) normal problem. It generates 1/s_j^2 randomly from a Gamma(s_alpha, s_beta) distribution
sim_ebnm_normal_data = function(n, mu, a, pi0, s_alpha, s_beta) {
  if ((mu != 0) & (pi0 > 0)) { # if trying to simulate from point-normal w/ mu != 0
    stop("If using point-normal prior, mu must be set to 0")
  }
  
  theta = rnorm(n, mean = mu, sd = sqrt(1/a))
  nonnulls = rbinom(n, size = 1, prob = 1 - pi0)
  theta = theta * nonnulls # change to 0 if null
  t = rgamma(n, shape = s_alpha, rate = s_beta) # 1/s_j^2
  s = sqrt(1 / t)
  x = rnorm(n, mean = theta, sd = s)
  return(list(x = x, s = s, theta = theta))
}

# Function to calculate results
calc_res = function(ebnm_fn, x, s, theta, g_start = NULL) {
  ebnm_res = ebnm_fn(x, s, g = g_start)
  par1 = ebnm_res$fitted_g[[1]] # mu for normal, pi0 for point-normal
  par2 = ebnm_res$fitted_g[[2]] # a for normal, a for point-normal
  MSE = mean((ebnm_res$result$PosteriorMean - theta)^2)
  ll = ebnm_res$loglik
  return(c(par1, par2, MSE, ll))
}



# This function simulates data B times, each time calculating the total computation time, the estimated values for mu and a, the MSE of the posterior mean in trying to recover theta, and the loglikelihood. Different starting values can be manually specified
# benchmark_name should be used when comparing different benchmark results
benchmark_ebnm_normal = function(ebnm_fn, B = 1000, n = 1000, mu = 0, a = .25, pi0 = 0, s_alpha = 2, s_beta = 20, g_start = NULL, bench_times = 5, bench_name = "", seed = 1138) {
  set.seed(seed)
  
  par_names = names(ebnm_fn(c(1,1), c(1, 1))$fitted_g) # c("mu", "a") or c("pi0", "a")
  
  res = data.frame(avg_time = numeric(B), par1 = numeric(B), par2 = numeric(B), MSE = numeric(B), ll = numeric(B))
  colnames(res)[grepl("^par[0-9]$", colnames(res))] = par_names
  
  for (i in 1:B) {
    xst = sim_ebnm_normal_data(n, mu, a, pi0, s_alpha, s_beta) # simulate data
    x = xst$x
    s = xst$s
    theta = xst$theta
    
    m = microbenchmark(ebnm_fn(x, s), times = bench_times)
    res[i, 1] = mean(m$time / 1e6) # milliseconds
    res[i, 2:5] = calc_res(ebnm_fn, x, s, theta, g_start)
  }
  
  res$name = bench_name
  return(res)
}


# This function takes a list of result dataframes, true parameter values. It plots comparisons of the different runs
# These should all have been run with the same parameter values, same seed, etc for consistency
compare_res = function(res_list, true_par1, true_par2) {
  n = length(res_list)
  cols = brewer.pal(n, "Dark2")[1:n]
  res_df = bind_rows(res_list)
  par_names = colnames(res_df)[2:3]
  
  # make sure boxplots are in correct order
  lvl = levels(as.factor(res_df$name))
  names(lvl) = lvl
  res_df$name_factor = factor(res_df$name, levels = lvl[unique(res_df$name)])
  
  # Avg Time
  boxplot(avg_time ~ name_factor, data = res_df, ylab = "Average Runtime (milliseconds)", main = "Comparison of Average Runtimes", xaxt = "n", xlab = "", outlne = F)
  points(jitter(as.numeric(res_df$name_factor)), res_df$avg_time, col = rep(cols, times = sapply(res_list, nrow)))
  axis(1, labels = F, tick = F)
  text(x =  seq_along(unique(res_df$name)), y = par("usr")[3], srt = 45, adj = 1, labels = unique(res_df$name), xpd = T)
  
  # MSE
  boxplot(MSE ~ name_factor, data = res_df, ylab = "MSE", main = "Comparison of MSEs", xaxt = "n", xlab = "", outlne = F)
  points(jitter(as.numeric(res_df$name_factor)), res_df$MSE, col = rep(cols, times = sapply(res_list, nrow)))
  axis(1, labels = F, tick = F)
  text(x =  seq_along(unique(res_df$name)), y = par("usr")[3], srt = 45, adj = 1, labels = unique(res_df$name), xpd = T)
  
  # log-lik
  boxplot(ll ~ name_factor, data = res_df, ylab = "Log-Likelihood", main = "Comparison of Log-Likelihoods", xaxt = "n", xlab = "", outlne = F)
  points(jitter(as.numeric(res_df$name_factor)), res_df$ll, col = rep(cols, times = sapply(res_list, nrow)))
  axis(1, labels = F, tick = F)
  text(x =  seq_along(unique(res_df$name)), y = par("usr")[3], srt = 45, adj = 1, labels = unique(res_df$name), xpd = T)
  
  # par1 (pi0 or mu)
  ## all on one plot
  d = res_list[[1]][, par_names[1]]
  plot(density(d), xlab = paste("MLE Estimate for ", par_names[1], sep = ""), main = paste("Density of Estimates for ", par_names[1], sep = ""), col = cols[1], ylim = c(0, 1.1 * max(density(d)$y)), lwd = 2)
  for (i in 2:n) {
    d = res_list[[i]][, par_names[1]]
    lines(density(d), col = cols[i], lwd = 2)
  }
  abline(v = true_par1, col = "red")
  legend("topright", legend = c(unique(res_df$name), "Truth"), fill = c(cols, "red"), bty = "n")
  
  ## all on different plots
  for (i in 1:n) {
    d = res_list[[i]][, par_names[1]]
    hist(d, xlab = paste("MLE Estimate for ", par_names[1], sep = ""), main = paste("Estimates for ", par_names[1], ": run ", unique(res_list[[i]]$name), sep = ""))
    abline(v = true_par1, col = "red")
  }
  
  # par2 (a)
  ## all on one plot
  d = res_list[[1]][, par_names[2]]
  plot_ind = (abs(d - true_par2) / true_par2 <= 2)
  
  plot(density(d[plot_ind]), xlab = paste("MLE Estimate for ", par_names[2], sep = ""), main = paste("Density of Estimates for ", par_names[2], sep = ""), col = cols[1], ylim = c(0, 1.1 * max(density(d[plot_ind])$y)), lwd = 2)
  if (sum(!plot_ind) > 1) { # if relative error > 200%
    warning(paste("Some fitted values for ", par_names[2], " in run ", unique(res_list[[1]]$name), " were very far from the true value. These should be inspected more closely", sep = ""))
  }
  for (i in 2:n) {
    d = res_list[[i]][, par_names[2]]
    plot_ind = (abs(d - true_par2) / true_par2 <= 2)
    
    lines(density(d[plot_ind]), col = cols[i], lwd = 2)
    if (sum(!plot_ind) > 1) { # if relative error > 200%
      warning(paste("Some fitted values for ", par_names[2], " in run ", unique(res_list[[i]]$name), " were very far from the true value. These should be inspected more closely", sep = ""))
    }
    #if (sum(plot_ind)) ADD CONDITION THAT IF TOO MANY ARE BAD, SKIP AND GIVE WARNING
  }
  abline(v = true_par2, col = "red")
  legend("topright", legend = c(unique(res_df$name), "Truth"), fill = c(cols, "red"), bty = "n")
  
  ## all on different plots
  for (i in 1:n) {
    d = res_list[[i]][, par_names[2]]
    hist(d, xlab = paste("MLE Estimate for ", par_names[2], sep = ""), main = paste("Estimates for ", par_names[2], ": run ", unique(res_list[[i]]$name), sep = ""))
    abline(v = true_par2, col = "red")
  }
}
