#' This function generates the data.
#' It sets the seed
#' It specifies which are non-nulls 
#' (it does this deterministically to get exactly the specified proportion of nulls)
#' It generates theta with the specified precision and mean
#' It generates x (given theta) with the specified standard deviations s

rnormmix_datamaker = function(seed, n, pi0, a, mu, s) {
  set.seed(seed)
  non_null = (1:n) > n * pi0 # just set first n*pi0 to be null
  true_pi0 = 1 - mean(non_null) # should be equal to args$pi0
  theta = non_null * rnorm(n, 0, 1/sqrt(a)) + mu
  
  x = rnorm(n, theta, s)
  
  return(list(theta = theta, true_pi0 = true_pi0, 
              true_a = a, true_mu = mu, x = x, s = s))
}

data = rnormmix_datamaker(seed, n, pi0, a, mu, s)
