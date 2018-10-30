#!/usr/bin/env dsc

# This DSC file is used for benchmarking the functions in the ebnm package
#
# SUMMARY
# =======
#
# PIPELINE VARIABLES
# $true_pi0        true pi0
# $true_a         true a
# $true_mu         true mu
# $theta        effects
# $input         data x and ses s
# $post_mean    posterior mean of effects
# $g_pi0        estimate of pi0
# $g_a    estimate of a
# $g_mu    estimate of mu
# $ll     log-likelihood
# $RMSE_theta    mean square error of effect estimates
# $RMSE_pi0         MSE of pi0 estimate
# RMSE_a         MSE of a estimate
# RMSE_mu         MSE of mu estimate
#
# MODULE TYPES
# name         inputs             outputs
# ----        ------            -------
# simulate     $true_pi0, $true_a, $true_mu    $theta, $input
# analyze      $inputs            $post_mean, $g_pi0, $g_a, $g_mu, $ll
# score        $theta, $post_mean,     $RMSE
#    $g_pi0, $g_a, $g_mu

# Simulate true effects from the point-normal distribution with mean 0,
# precision a, and null component weight pi0.
simulate: datamaker.R
  # input
  seed: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
  mu: 0
  n: 1000
  pi0: 0, .2, .5, .8, 1
  a: 1/25, 1/16, 1/4
  @ALIAS: args = List()
  # output
  $data: data
  $theta: data$meta$theta
  $true_pi0: data$meta$true_pi0
  $true_a: data$meta$true_a
  $true_mu: data$meta$true_mu

# Run ebnm on problem
eb: runebnm.R
    # input
    prior_in: 1
    fix_mu_in: 0, 1
    @ALIAS: args = List()
    data: $data
    # output
    $ebnm_data: ebnm_data
    $prior: ebnm_data$prior
    $fix_mu: ebnm_data$fix_mu
    $post_mean: ebnm_data$pm
    $g_pi0: ebnm_data$fitted_g$pi0
    $g_a: ebnm_data$fitted_g$a
    $g_mu: ebnm_data$fitted_g$mu
    $loglik: ebnm_data$loglik

# Score by MSE
score_theta: score.R
    est: $post_mean
    truth: $theta
    $RMSE: result

score_pi0: score.R
    est: $g_pi0
    truth: $true_pi0
    $RMSE: result

score_a: score.R
    est: $g_a
    truth: $true_a
    $RMSE: result

score_mu: score.R
    est: $g_mu
    truth: $true_mu
    $RMSE: result


DSC:
  define:
    score: score_theta, score_pi0, score_a, score_mu
  run: simulate * eb * score
