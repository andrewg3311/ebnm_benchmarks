score = function(est, truth) {
  MSE = sqrt(mean((est - truth)^2))
  MAD = median(abs(est - truth))
  return(list(MSE = MSE, MAD = MAD))
}

result = score(est, truth)
