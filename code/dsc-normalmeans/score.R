score = function(est, truth) {
  RMSE = sqrt(mean((est - truth)^2))
  MAD = median(abs(est - truth))
  return(list(RMSE = RMSE, MAD = MAD))
}

result = score(est, truth)
