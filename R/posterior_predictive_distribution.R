#
# Functions for generating a posterior predictive distributions 
# for 2x2 recognition experiments
#


library(mvtnorm)

getPVec = function(mu, rho, xMat){
  
  p = c()
  
  for(i in 1:4){
    rho_ = rho * prod(xMat[i,])
    p[i] = pmvnorm(c(-Inf, -Inf), mu * xMat[i,], c(0, 0), 
                   matrix(c(1, rho_, rho_, 1), 2, 2))[1]
  }
  
  # Just to make sure that the distribution
  # is a probability distribution: 
  # (probably should throw warnings if assumptions are
  # violated gravely)
  
  p[p < 0] = 0
  p = p / sum(p)
  sum(p)
  
  return(p)
}

genRandSlice = function(N, mu, rho, xMat){
  # Returns the full "response" vector for a given latent
  # distribution defined by the vector of mus and rho. 
  # 
  # Retuns something like this:
  # [1]  14  45  34 157

  if(length(rho) != 1){
    stop("You should supply just a single correlation coefficient")
  }

  if(rho > 1.0 || rho < -1-0){
    stop(paste("Correlation was not in the range (-1 1), was", rho))
  }

  if(length(mu) != 2){
    stop(paste("Incorrect number of dimensions in mu vector, expected 2 but was", length(mu)))
  }
  
  cats = sample(1:4, N, T, getPVec(mu, rho, xMat))
  
  return(as.vector(table(factor(cats, levels = 1:4))))
}

simulateCmat = function(NPerRow, theta, xMat){
  #
  # At this point, this supports the following models:
  # - 2x2 one rho
  # - 2x2 four rhos
  #
  # NPerRow: Total number of observations per stimulus
  # Theta  : A slice of the posterior from Stan
  
  mu_mat  = matrix(theta[1:8], ncol = 2, nrow = 4)
  if(length(theta) == 13){
    rho_vec = tanh(theta[9:12])
  } else if(length(theta) == 10){
    rho_vec = rep(tanh(theta[9]), 4)
  } else {
    stop("Incorrect number of parameters in a posterior draw.")
  }
  
  sim_cmat = matrix(NaN, nrow = 4, ncol = 4)
  
  for(i in 1:4){
    sim_cmat[i,] = genRandSlice(NPerRow, mu_mat[i,], rho_vec[i], xMat)
  }
  
  return(sim_cmat)
}

genPosteriorPredictive = function(stanfit, xMat, NSimulations, NPerRow){
  #
  # Generates a three-dimensional array of simulated data sets, in which
  # the first index indexes the simulated data sets.
  #
  # INPUT
  # stanfit: a stanfit object, containing samples from either:
  #    - mdl2x2_one_rho.stan or  
  #    - mdl2x2_four_rhos.stan
  #
  # xMat: matrix defining the order of stimuli in the confusion matrix, should
  #   contain only -1:s and 1:s
  #
  # NSimulations: how many posterior predictive data sets to simulate
  #
  # NPerRow: how may observations there are per row (stimulus) in the original 
  #   confusion matrix.
  
  if(!any(dim(xMat) == c(4, 2))){
    stop("xMat is not defined properly. Should have 4 rows and 2 columns,
         preferably just -1:s and 1:s, set up correctly, but I'll leave 
         that to you.")
  }
  
  posterior_draws = as.matrix(stanfit) 
  
  if(nrow(posterior_draws) < NSimulations){
    warning(paste(NSimulations, "posterior draws asked, but only", 
                  nrow(posterior_draws), "samples in the stanfit object."))
    NSimulations = nrow(posterior_draws)
  }

  simulated_matrices = array(NaN, dim = c(NSimulations, 4, 4))
  
  for(i in 1:NSimulations){
    simulated_matrices[i,,] = simulateCmat(NPerRow, posterior_draws[i,], xMat)
  }
  
  return(simulated_matrices)
}

plotPostPred = function(postpred, obs){
  #
  # Draws a 4 by 4 grid of posterior predictive counts as histograms
  # and sticks a red vertical line where the observed count is. 
  #
  # INPUT:
  # postpred: a three-dimensional array of posterior predictive counts 
  #           as returned by the function genPosteriorPredictive.
  # 
  # obs: a 4x4 confusion matrix of observed counts.
  #
  
  opar = par(no.readonly = T)
  
  par(mfrow = c(4,4))
  par(mar = c(2.1, 2.1, 2.1, 2.1))
  
  for(i in 1:4){
    for(j in 1:4){
      hist(postpred[,i,j], main = "", xlab = "", ylab = "")
      abline(v = obs[i,j], col = "red", lwd = 2)
    }
  }
  
  par(opar) 
}


