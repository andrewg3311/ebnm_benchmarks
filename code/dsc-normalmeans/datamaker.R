rnormmix_datamaker = function(args) {
  set.seed(args$seed)
  non_null = (1:args$n) > args$n * args$pi0 # just set first n*pi0 to be null
  true_pi0 = 1 - mean(non_null) # should be equal to args$pi0
  theta = non_null * rnorm(args$n, 0, 1/sqrt(args$a)) + args$mu
  meta = list(theta = theta, true_pi0 = true_pi0, true_a = args$a, true_mu = args$mu)
  
  x = rnorm(args$n, theta, args$s)
  
  input = list(x = x, s = args$s)
  
  data = list(meta = meta, input = input)
  
  return(data)
}

data = rnormmix_datamaker(args)
