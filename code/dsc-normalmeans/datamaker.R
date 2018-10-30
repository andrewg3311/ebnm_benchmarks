rnormmix_datamaker = function(args) {
  set.seed(args$seed)
  non_null = rbinom(args$n, 1, (1 - args$pi0))
  true_pi0 = 1 - mean(non_null)
  theta = non_null * rnorm(args$n, 0, 1/sqrt(args$a)) + args$mu
  meta = list(theta = theta, true_pi0 = true_pi0, true_a = args$a, true_mu = args$mu)
  
  x = rnorm(args$n, theta, args$s)
  
  input = list(x = x, s = args$s)
  
  data = list(meta = meta, input = input)
  
  return(data)
}

data = rnormmix_datamaker(args)
